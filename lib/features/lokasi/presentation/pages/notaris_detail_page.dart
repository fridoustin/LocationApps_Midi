import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/notaris.dart';
import 'package:midi_location/features/lokasi/presentation/pages/history_notaris_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/status_badge.dart';

class NotarisDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const NotarisDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notarisAsync = ref.watch(notarisDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Notaris',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: notarisAsync.when(
        data: (notaris) => notaris == null
            ? const EmptyState(
                title: 'Data Notaris Belum Tersedia',
                message: 'Belum ada data Notaris untuk KPLT ini',
              )
            : _NotarisContent(
                notaris: notaris,
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
          onRetry: () => ref.invalidate(notarisDataProvider(progressKpltId)),
        ),
      ),
    );
  }
}

class _NotarisContent extends StatelessWidget {
  final Notaris notaris;
  final String kpltName;

  const _NotarisContent({
    required this.notaris,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card with History Button
          DetailHeaderCard(
            title: kpltName,
            subtitle: 'Notaris',
            icon: Icons.account_balance,
            statusBadge: StatusBadge(isCompleted: notaris.isCompleted),
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryNotarisPage(
                    notarisId: notaris.id,
                    kpltName: kpltName,
                  ),
                ),
              );
            },
            historyLabel: 'Lihat History Notaris',
          ),
          const SizedBox(height: 16),

          // PAR Section
          DetailSectionCard(
            title: 'PAR',
            icon: Icons.description_outlined,
            children: [
              InfoRow(
                label: 'Tanggal PAR',
                value: DateFormatter.formatDate(notaris.tglPar),
              ),
              if (notaris.filePar != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File PAR',
                  filePath: notaris.filePar!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    notaris.filePar,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Status Legal Section
          DetailSectionCard(
            title: 'Status Legal',
            icon: Icons.gavel,
            children: [
              InfoRow(
                label: 'Validasi Legal',
                value: notaris.validasiLegal ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Validasi Legal',
                value: DateFormatter.formatDate(notaris.tglValidasiLegal),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notaris Section
          DetailSectionCard(
            title: 'Notaris',
            icon: Icons.assignment_ind,
            children: [
              InfoRow(
                label: 'Status Notaris',
                value: notaris.statusNotaris ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Plan Notaris',
                value: DateFormatter.formatDate(notaris.tglPlanNotaris),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Notaris',
                value: DateFormatter.formatDate(notaris.tglNotaris),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Pembayaran Section
          DetailSectionCard(
            title: 'Status Pembayaran',
            icon: Icons.payment,
            children: [
              InfoRow(
                label: 'Status Pembayaran',
                value: notaris.statusPembayaran ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Pembayaran',
                value: DateFormatter.formatDate(notaris.tglPembayaran),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Informasi Tambahan Section
          DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              if (notaris.tglSelesaiNotaris != null)
                InfoRow(
                  label: 'Tanggal Selesai',
                  value: DateFormatter.formatDate(notaris.tglSelesaiNotaris),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}