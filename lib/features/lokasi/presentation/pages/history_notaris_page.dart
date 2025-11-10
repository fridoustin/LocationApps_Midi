import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/notaris.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/compact_file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_card_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_section_title.dart';

class HistoryNotarisPage extends ConsumerWidget {
  final String notarisId;
  final String kpltName;

  const HistoryNotarisPage({
    super.key,
    required this.notarisId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotarisProvider(notarisId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'History Notaris',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) => historyList.isEmpty
            ? const EmptyState(
                title: 'Belum Ada History',
                message: 'Belum ada history notaris untuk data ini',
                icon: Icons.history,
              )
            : _HistoryNotarisList(
                historyList: historyList,
                kpltName: kpltName,
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            color: AppColors.primaryColor,
          ),
        ),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(historyNotarisProvider(notarisId)),
        ),
      ),
    );
  }
}

class _HistoryNotarisList extends StatelessWidget {
  final List<HistoryNotaris> historyList;
  final String kpltName;

  const _HistoryNotarisList({
    required this.historyList,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HistoryHeader(title: kpltName, historyCount: historyList.length),
          const SizedBox(height: 16),
          ...historyList.asMap().entries.map((entry) {
            final index = entry.key;
            final history = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == historyList.length - 1 ? 0 : 16,
              ),
              child: _HistoryNotarisCard(
                history: history,
                number: index + 1,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HistoryNotarisCard extends StatelessWidget {
  final HistoryNotaris history;
  final int number;

  const _HistoryNotarisCard({
    required this.history,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryCardHeader(number: number, createdAt: history.createdAt),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // PAR Section
          if (history.filePar != null || history.tglPar != null) ...[
            const HistorySectionTitle(title: 'PAR'),
            const SizedBox(height: 8),
            if (history.tglPar != null)
              HistoryInfoRow(
                label: 'Tanggal PAR',
                value: DateFormatter.formatDate(history.tglPar),
              ),
            if (history.filePar != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File PAR',
                filePath: history.filePar!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.filePar,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Status Legal Section
          if (history.validasiLegal != null ||
              history.tglValidasiLegal != null) ...[
            const HistorySectionTitle(title: 'Status Legal'),
            const SizedBox(height: 8),
            if (history.validasiLegal != null)
              HistoryInfoRow(label: 'Status', value: history.validasiLegal!),
            if (history.validasiLegal != null &&
                history.tglValidasiLegal != null)
              const SizedBox(height: 8),
            if (history.tglValidasiLegal != null)
              HistoryInfoRow(
                label: 'Tanggal Validasi',
                value: DateFormatter.formatDate(history.tglValidasiLegal),
              ),
            const SizedBox(height: 16),
          ],

          // Notaris Section
          if (history.statusNotaris != null || history.tglNotaris != null) ...[
            const HistorySectionTitle(title: 'Notaris'),
            const SizedBox(height: 8),
            if (history.statusNotaris != null)
              HistoryInfoRow(label: 'Status', value: history.statusNotaris!),
            if (history.statusNotaris != null &&
                history.tglPlanNotaris != null)
              const SizedBox(height: 8),
            if (history.tglPlanNotaris != null)
              HistoryInfoRow(
                label: 'Tanggal Plan',
                value: DateFormatter.formatDate(history.tglPlanNotaris),
              ),
            if (history.tglNotaris != null) ...[
              const SizedBox(height: 8),
              HistoryInfoRow(
                label: 'Tanggal Notaris',
                value: DateFormatter.formatDate(history.tglNotaris),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Status Pembayaran Section
          if (history.statusPembayaran != null ||
              history.tglPembayaran != null) ...[
            const HistorySectionTitle(title: 'Status Pembayaran'),
            const SizedBox(height: 8),
            if (history.statusPembayaran != null)
              HistoryInfoRow(
                label: 'Status',
                value: history.statusPembayaran!,
              ),
            if (history.statusPembayaran != null &&
                history.tglPembayaran != null)
              const SizedBox(height: 8),
            if (history.tglPembayaran != null)
              HistoryInfoRow(
                label: 'Tanggal',
                value: DateFormatter.formatDate(history.tglPembayaran),
              ),
          ],
        ],
      ),
    );
  }
}