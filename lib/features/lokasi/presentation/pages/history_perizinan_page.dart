import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/perizinan.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/compact_file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_card_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_section_title.dart';

class HistoryPerizinanPage extends ConsumerWidget {
  final String perizinanId;
  final String kpltName;

  const HistoryPerizinanPage({
    super.key,
    required this.perizinanId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyPerizinanProvider(perizinanId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'History Perizinan',
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
                message: 'Belum ada history perizinan untuk data ini',
                icon: Icons.history,
              )
            : _HistoryPerizinanList(
                historyList: historyList,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(historyPerizinanProvider(perizinanId)),
        ),
      ),
    );
  }
}

class _HistoryPerizinanList extends StatelessWidget {
  final List<HistoryPerizinan> historyList;
  final String kpltName;

  const _HistoryPerizinanList({
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
              child: _HistoryPerizinanCard(
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

class _HistoryPerizinanCard extends StatelessWidget {
  final HistoryPerizinan history;
  final int number;

  const _HistoryPerizinanCard({
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

          // SPH Section
          if (history.nominalSph != null || history.tglSph != null) ...[
            const HistorySectionTitle(title: 'SPH'),
            const SizedBox(height: 8),
            if (history.nominalSph != null)
              HistoryInfoRow(
                label: 'Nominal SPH',
                value: DateFormatter.formatCurrency(history.nominalSph),
              ),
            if (history.nominalSph != null && history.tglSph != null)
              const SizedBox(height: 8),
            if (history.tglSph != null)
              HistoryInfoRow(
                label: 'Tanggal SPH',
                value: DateFormatter.formatDate(history.tglSph),
              ),
            if (history.fileSph != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File SPH',
                filePath: history.fileSph!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileSph,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Status Berkas Section
          if (history.statusBerkas != null || history.tglStBerkas != null) ...[
            const HistorySectionTitle(title: 'Status Berkas'),
            const SizedBox(height: 8),
            if (history.statusBerkas != null)
              HistoryInfoRow(label: 'Status', value: history.statusBerkas!),
            if (history.statusBerkas != null && history.tglStBerkas != null)
              const SizedBox(height: 8),
            if (history.tglStBerkas != null)
              HistoryInfoRow(
                label: 'Tanggal ST',
                value: DateFormatter.formatDate(history.tglStBerkas),
              ),
            if (history.fileBuktiSt != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File Bukti ST',
                filePath: history.fileBuktiSt!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileBuktiSt,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Gambar Denah Section
          if (history.statusGambarDenah != null ||
              history.tglGambarDenah != null) ...[
            const HistorySectionTitle(title: 'Gambar Denah'),
            const SizedBox(height: 8),
            if (history.statusGambarDenah != null)
              HistoryInfoRow(label: 'Status', value: history.statusGambarDenah!),
            if (history.statusGambarDenah != null &&
                history.tglGambarDenah != null)
              const SizedBox(height: 8),
            if (history.tglGambarDenah != null)
              HistoryInfoRow(
                label: 'Tanggal',
                value: DateFormatter.formatDate(history.tglGambarDenah),
              ),
            if (history.fileDenah != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File Denah',
                filePath: history.fileDenah!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileDenah,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // OSS Section
          if (history.oss != null || history.tglOss != null) ...[
            const HistorySectionTitle(title: 'OSS'),
            const SizedBox(height: 8),
            if (history.oss != null)
              HistoryInfoRow(label: 'OSS', value: history.oss!),
            if (history.oss != null && history.tglOss != null)
              const SizedBox(height: 8),
            if (history.tglOss != null)
              HistoryInfoRow(
                label: 'Tanggal OSS',
                value: DateFormatter.formatDate(history.tglOss),
              ),
            const SizedBox(height: 16),
          ],

          // SPK Section
          if (history.statusSpk != null || history.tglSpk != null) ...[
            const HistorySectionTitle(title: 'SPK'),
            const SizedBox(height: 8),
            if (history.statusSpk != null)
              HistoryInfoRow(label: 'Status SPK', value: history.statusSpk!),
            if (history.statusSpk != null && history.tglSpk != null)
              const SizedBox(height: 8),
            if (history.tglSpk != null)
              HistoryInfoRow(
                label: 'Tanggal SPK',
                value: DateFormatter.formatDate(history.tglSpk),
              ),
            if (history.fileSpk != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File SPK',
                filePath: history.fileSpk!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileSpk,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Rekomendasi Notaris Section
          if (history.rekomNotarisVendor != null ||
              history.tglRekomNotaris != null) ...[
            const HistorySectionTitle(title: 'Rekomendasi Notaris'),
            const SizedBox(height: 8),
            if (history.rekomNotarisVendor != null)
              HistoryInfoRow(
                label: 'Vendor',
                value: history.rekomNotarisVendor!,
              ),
            if (history.rekomNotarisVendor != null &&
                history.tglRekomNotaris != null)
              const SizedBox(height: 8),
            if (history.tglRekomNotaris != null)
              HistoryInfoRow(
                label: 'Tanggal',
                value: DateFormatter.formatDate(history.tglRekomNotaris),
              ),
            if (history.fileRekomNotaris != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File Rekomendasi',
                filePath: history.fileRekomNotaris!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileRekomNotaris,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}