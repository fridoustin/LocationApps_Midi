// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';

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
        data: (mou) {
          if (mou == null) {
            return _buildEmptyState();
          }
          return _buildMouContent(mou);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(err.toString(), ref),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data MOU Belum Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data MOU untuk KPLT ini',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(mouDataProvider(progressKpltId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMouContent(Mou mou) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(mou),
          const SizedBox(height: 16),

          // Status Card
          _buildStatusCard(mou),
          const SizedBox(height: 16),

          // Informasi Pemilik
          _buildSectionCard(
            title: 'Informasi Pemilik',
            icon: Icons.person,
            children: [
              _buildInfoRow('Nama Pemilik Final', mou.namaPemilikFinal ?? '-'),
            ],
          ),
          const SizedBox(height: 16),

          // Detail Sewa
          _buildSectionCard(
            title: 'Detail Sewa',
            icon: Icons.home_work,
            children: [
              _buildInfoRow(
                'Periode Sewa',
                mou.periodeSewa != null ? '${mou.periodeSewa} bulan' : '-',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Nilai Sewa',
                mou.nilaiSewa != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(mou.nilaiSewa)
                    : '-',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Harga Final',
                mou.hargaFinal != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(mou.hargaFinal)
                    : '-',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Grace Period',
                mou.gracePeriod != null ? '${mou.gracePeriod} hari' : '-',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pembayaran & Pajak
          _buildSectionCard(
            title: 'Pembayaran & Pajak',
            icon: Icons.payment,
            children: [
              _buildInfoRow('Cara Pembayaran', mou.caraPembayaran ?? '-'),
              const SizedBox(height: 12),
              _buildInfoRow('Status Pajak', mou.statusPajak ?? '-'),
              const SizedBox(height: 12),
              _buildInfoRow('Pembayaran PPh', mou.pembayaranPph ?? '-'),
            ],
          ),
          const SizedBox(height: 16),

          // Tanggal & Keterangan
          _buildSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow(
                'Tanggal MOU',
                mou.tanggalMou != null
                    ? DateFormat('dd MMMM yyyy').format(mou.tanggalMou!)
                    : '-',
              ),
              if (mou.tglSelesaiMou != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Tanggal Selesai',
                  DateFormat('dd MMMM yyyy').format(mou.tglSelesaiMou!),
                ),
              ],
              if (mou.keterangan != null && mou.keterangan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Keterangan', mou.keterangan!),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Mou mou) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.handshake,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MOU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kpltName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Mou mou) {
    final isCompleted = mou.isCompleted;
    final statusColor = isCompleted ? AppColors.successColor : Colors.orange;
    final statusText = isCompleted ? 'Selesai' : 'Dalam Proses';
    final statusIcon = isCompleted ? Icons.check_circle : Icons.pending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status MOU',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}