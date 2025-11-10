import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/perizinan.dart';
import 'package:midi_location/features/lokasi/presentation/pages/history_perizinan_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/status_badge.dart';

class PerizinanDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const PerizinanDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perizinanAsync = ref.watch(perizinanDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Perizinan',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: perizinanAsync.when(
        data: (perizinan) => perizinan == null
            ? const EmptyState(
                title: 'Data Perizinan Belum Tersedia',
                message: 'Belum ada data Perizinan untuk KPLT ini',
              )
            : _PerizinanContent(
                perizinan: perizinan,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(perizinanDataProvider(progressKpltId)),
        ),
      ),
    );
  }
}

class _PerizinanContent extends StatelessWidget {
  final Perizinan perizinan;
  final String kpltName;

  const _PerizinanContent({
    required this.perizinan,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          DetailHeaderCard(
            title: kpltName,
            subtitle: 'Perizinan',
            icon: Icons.description,
            statusBadge: StatusBadge(isCompleted: perizinan.isCompleted),
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPerizinanPage(
                    perizinanId: perizinan.id,
                    kpltName: kpltName,
                  ),
                ),
              );
            },
            historyLabel: 'Lihat History Perizinan',
          ),
          const SizedBox(height: 16),

          // SPH Section
          DetailSectionCard(
            title: 'SPH',
            icon: Icons.email,
            children: [
              InfoRow(
                label: 'Nominal SPH',
                value: DateFormatter.formatCurrency(perizinan.nominalSph),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal SPH',
                value: DateFormatter.formatDate(perizinan.tglSph),
              ),
              if (perizinan.fileSph != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File SPH',
                  filePath: perizinan.fileSph!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    perizinan.fileSph,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Status Berkas Section
          DetailSectionCard(
            title: 'Status Berkas',
            icon: Icons.folder_open,
            children: [
              InfoRow(
                label: 'Status Berkas',
                value: perizinan.statusBerkas ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal ST Berkas',
                value: DateFormatter.formatDate(perizinan.tglStBerkas),
              ),
              if (perizinan.fileBuktiSt != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File Bukti ST',
                  filePath: perizinan.fileBuktiSt!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    perizinan.fileBuktiSt,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Gambar Denah Section
          DetailSectionCard(
            title: 'Gambar Denah',
            icon: Icons.architecture,
            children: [
              InfoRow(
                label: 'Status Gambar Denah',
                value: perizinan.statusGambarDenah ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Gambar Denah',
                value: DateFormatter.formatDate(perizinan.tglGambarDenah),
              ),
              if (perizinan.fileDenah != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File Denah',
                  filePath: perizinan.fileDenah!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    perizinan.fileDenah,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // OSS Section
          DetailSectionCard(
            title: 'OSS',
            icon: Icons.web,
            children: [
              InfoRow(label: 'OSS', value: perizinan.oss ?? '-'),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal OSS',
                value: DateFormatter.formatDate(perizinan.tglOss),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SPK Section
          DetailSectionCard(
            title: 'SPK',
            icon: Icons.assignment,
            children: [
              InfoRow(
                label: 'Status SPK',
                value: perizinan.statusSpk ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal SPK',
                value: DateFormatter.formatDate(perizinan.tglSpk),
              ),
              if (perizinan.fileSpk != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File SPK',
                  filePath: perizinan.fileSpk!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    perizinan.fileSpk,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Rekomendasi Notaris Section
          DetailSectionCard(
            title: 'Rekomendasi Notaris',
            icon: Icons.account_balance,
            children: [
              InfoRow(
                label: 'Rekomendasi Notaris Vendor',
                value: perizinan.rekomNotarisVendor ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Rekomendasi',
                value: DateFormatter.formatDate(perizinan.tglRekomNotaris),
              ),
              if (perizinan.fileRekomNotaris != null) ...[
                const SizedBox(height: 12),
                FileRow(
                  label: 'File Rekomendasi Notaris',
                  filePath: perizinan.fileRekomNotaris!,
                  onTap: () => FileService.openOrDownloadFile(
                    context,
                    perizinan.fileRekomNotaris,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Informasi Tambahan Section
          DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              if (perizinan.tglSelesaiPerizinan != null)
                InfoRow(
                  label: 'Tanggal Selesai',
                  value: DateFormatter.formatDate(perizinan.tglSelesaiPerizinan),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}