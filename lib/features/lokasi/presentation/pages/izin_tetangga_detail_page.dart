import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/izin_tetangga.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';

class IzinTetanggaDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const IzinTetanggaDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final izinTetanggaAsync = ref.watch(izinTetanggaDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Izin Tetangga',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: izinTetanggaAsync.when(
        data: (izinTetangga) => izinTetangga == null
            ? const EmptyState(
                title: 'Data izin tetangga belum tersedia', 
                message: 'Belum ada data izin tetangga untuk KPLT ini',
              )
            : _IzinTetanggaContent(
                data: izinTetangga,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              color: AppColors.primaryColor,
        )),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(izinTetanggaDataProvider(progressKpltId)),
        )
      ),
    );
  }
}

class _IzinTetanggaContent extends StatelessWidget {
  final IzinTetangga data;
  final String kpltName;

  const _IzinTetanggaContent({
    required this.data,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DetailHeaderCard(
            title: kpltName, 
            subtitle: 'Izin Tetangga', 
            icon: Icons.people
          ),
          const SizedBox(height: 16),
          DetailSectionCard(
            title: 'Informasi Umum', 
            icon: Icons.info, 
            children: [
              InfoRow(
                label: 'Nominal',
                value: DateFormatter.formatCurrency(data.nominal)
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Terbit', 
                value: DateFormatter.formatDate(data.tanggalTerbit)
              ),
              if (data.tglSelesaiIzintetangga != null) ...[
                const SizedBox(height: 12),
                InfoRow(
                  label: 'Tanggal Selesai', 
                  value: DateFormatter.formatDate(data.tglSelesaiIzintetangga)
                ),
              ],
            ]
          ),
          const SizedBox(height: 16),
          if (data.fileIzinTetangga != null || data.fileBuktiPembayaran != null)...[
            DetailSectionCard(
              title: 'Dokumen', 
              icon: Icons.folder, 
              children: [
                if (data.fileIzinTetangga != null) ...[
                  FileRow(
                    label: 'File Izin Tetangga', 
                    filePath: data.fileIzinTetangga!, 
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      data.fileIzinTetangga,
                    )
                  ),
                  if (data.fileBuktiPembayaran != null) const SizedBox(height: 12),
                ],
                if (data.fileBuktiPembayaran != null) ...[
                  FileRow(
                    label: 'File Bukti Pembayaran', 
                    filePath: data.fileBuktiPembayaran!, 
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      data.fileBuktiPembayaran,
                    )
                  ),
                ]
              ]
            )
          ]
        ],
      ),
    );
  }
}