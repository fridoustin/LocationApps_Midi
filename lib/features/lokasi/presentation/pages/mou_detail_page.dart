import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/status_badge.dart';

class MouDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const MouDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mouAsync = ref.watch(mouDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail MOU',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: mouAsync.when(
        data: (mou) => mou == null
            ? const EmptyState(
                title: 'Data MOU Belum Tersedia',
                message: 'Belum ada data MOU untuk KPLT ini',
              )
            : _MouContent(mou: mou, kpltName: kpltName),
        loading: () => const Center(child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              color: AppColors.primaryColor,
        )),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(mouDataProvider(progressKpltId)),
        ),
      ),
    );
  }
}

class _MouContent extends StatelessWidget {
  final Mou mou;
  final String kpltName;

  const _MouContent({required this.mou, required this.kpltName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DetailHeaderCard(
            title: kpltName,
            subtitle: 'MOU',
            icon: Icons.handshake,
            statusBadge: StatusBadge(isCompleted: mou.isCompleted),
          ),
          const SizedBox(height: 16),
          DetailSectionCard(
            title: 'Informasi Pemilik',
            icon: Icons.person,
            children: [
              InfoRow(
                label: 'Nama Pemilik Final',
                value: mou.namaPemilikFinal ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),
          DetailSectionCard(
            title: 'Detail Sewa',
            icon: Icons.home_work,
            children: [
              InfoRow(
                label: 'Periode Sewa',
                value: mou.periodeSewa != null 
                    ? '${mou.periodeSewa} bulan' 
                    : '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Nilai Sewa',
                value: DateFormatter.formatCurrency(mou.nilaiSewa),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Harga Final',
                value: DateFormatter.formatCurrency(mou.hargaFinal),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Grace Period',
                value: mou.gracePeriod != null 
                    ? '${mou.gracePeriod} hari' 
                    : '-',
              ),
            ],
          ),
          const SizedBox(height: 16),
          DetailSectionCard(
            title: 'Pembayaran & Pajak',
            icon: Icons.payment,
            children: [
              InfoRow(
                label: 'Cara Pembayaran',
                value: mou.caraPembayaran ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(label: 'Status Pajak', value: mou.statusPajak ?? '-'),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Pembayaran PPh',
                value: mou.pembayaranPph ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),
          DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              InfoRow(
                label: 'Tanggal MOU',
                value: DateFormatter.formatDate(mou.tanggalMou),
              ),
              if (mou.tglSelesaiMou != null) ...[
                const SizedBox(height: 12),
                InfoRow(
                  label: 'Tanggal Selesai',
                  value: DateFormatter.formatDate(mou.tglSelesaiMou),
                ),
              ],
              if (mou.keterangan != null && mou.keterangan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                InfoRow(label: 'Keterangan', value: mou.keterangan!),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}