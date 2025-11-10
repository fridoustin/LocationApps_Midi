import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/renovasi.dart';
import 'package:midi_location/features/lokasi/presentation/pages/history_renovasi_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/progress_tracking_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/status_badge.dart';

class RenovasiDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const RenovasiDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renovasiAsync = ref.watch(renovasiDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Renovasi',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: renovasiAsync.when(
        data: (renovasi) => renovasi == null
            ? const EmptyState(
                title: 'Data Renovasi Belum Tersedia',
                message: 'Belum ada data Renovasi untuk KPLT ini',
              )
            : _RenovasiContent(
                renovasi: renovasi,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(renovasiDataProvider(progressKpltId)),
        ),
      ),
    );
  }
}

class _RenovasiContent extends StatelessWidget {
  final Renovasi renovasi;
  final String kpltName;

  const _RenovasiContent({
    required this.renovasi,
    required this.kpltName,
  });

  bool get _hasProgressData {
    return renovasi.planRenov != null ||
        renovasi.prosesRenov != null ||
        renovasi.deviasi != null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          DetailHeaderCard(
            title: kpltName,
            subtitle: 'Renovasi',
            icon: Icons.construction,
            statusBadge: StatusBadge(isCompleted: renovasi.isCompleted),
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryRenovasiPage(
                    renovasiId: renovasi.id,
                    kpltName: kpltName,
                  ),
                ),
              );
            },
            historyLabel: 'Lihat History Renovasi',
          ),
          const SizedBox(height: 16),

          // Progress Tracking Card (if data exists)
          if (_hasProgressData) ...[
            ProgressTrackingCard(
              planPercentage: renovasi.planRenov,
              prosesPercentage: renovasi.prosesRenov,
              deviasi: renovasi.deviasi,
              progressStatus: renovasi.progressStatus,
              deviasiStatus: renovasi.deviasiStatus,
              progressColor: renovasi.progressColor,
            ),
            const SizedBox(height: 16),
          ],

          // Informasi Store Section
          DetailSectionCard(
            title: 'Informasi Store',
            icon: Icons.store,
            children: [
              InfoRow(
                label: 'Kode Store',
                value: renovasi.kodeStore ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tipe Toko',
                value: renovasi.tipeToko ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Bentuk Objek',
                value: renovasi.bentukObjek ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rekomendasi Renovasi Section
          DetailSectionCard(
            title: 'Rekomendasi Renovasi',
            icon: Icons.recommend,
            children: [
              InfoRow(
                label: 'Rekomendasi',
                value: renovasi.rekomRenovasi ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Rekomendasi',
                value: DateFormatter.formatDate(renovasi.tglRekomRenovasi),
              ),
              if (renovasi.fileRekomRenovasi != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File Rekomendasi',
                  filePath: renovasi.fileRekomRenovasi!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    renovasi.fileRekomRenovasi,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // SPK Renovasi Section
          DetailSectionCard(
            title: 'SPK Renovasi',
            icon: Icons.assignment,
            children: [
              InfoRow(
                label: 'Start SPK',
                value: DateFormatter.formatDate(renovasi.startSpkRenov),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'End SPK',
                value: DateFormatter.formatDate(renovasi.endSpkRenov),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Informasi Tambahan Section
          DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              InfoRow(
                label: 'Tanggal Serah Terima',
                value: DateFormatter.formatDate(renovasi.tglSerahTerima),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Terakhir Diupdate',
                value: DateFormatter.formatDateTime(renovasi.updatedAt),
              ),
              if (renovasi.tglSelesaiRenov != null) ...[
                const SizedBox(height: 12),
                InfoRow(
                  label: 'Tanggal Selesai',
                  value: DateFormatter.formatDate(renovasi.tglSelesaiRenov),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}