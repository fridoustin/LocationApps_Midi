// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/izin_tetangga.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        data: (izinTetangga) {
          if (izinTetangga == null) {
            return _buildEmptyState();
          }
          return _buildContent(context, izinTetangga);
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
              'Data Izin Tetangga Belum Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data Izin Tetangga untuk KPLT ini',
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
              onPressed: () => ref.invalidate(izinTetanggaDataProvider(progressKpltId)),
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

  Widget _buildContent(BuildContext context, IzinTetangga data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(data),
          const SizedBox(height: 16),

          // Informasi Umum
          _buildSectionCard(
            title: 'Informasi Umum',
            icon: Icons.info,
            children: [
              _buildInfoRow(
                'Nominal',
                data.nominal != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(data.nominal)
                    : '-',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Tanggal Terbit',
                data.tanggalTerbit != null
                    ? DateFormat('dd MMMM yyyy').format(data.tanggalTerbit!)
                    : '-',
              ),
              if (data.tglSelesaiIzintetangga != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Tanggal Selesai',
                  DateFormat('dd MMMM yyyy').format(data.tglSelesaiIzintetangga!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Dokumen
          if (data.fileIzinTetangga != null || data.fileBuktiPembayaran != null)
            _buildSectionCard(
              title: 'Dokumen',
              icon: Icons.folder,
              children: [
                if (data.fileIzinTetangga != null) ...[
                  _buildFileRow(
                    context,
                    'File Izin Tetangga',
                    data.fileIzinTetangga!,
                  ),
                  if (data.fileBuktiPembayaran != null) const SizedBox(height: 12),
                ],
                if (data.fileBuktiPembayaran != null)
                  _buildFileRow(
                    context,
                    'File Bukti Pembayaran',
                    data.fileBuktiPembayaran!,
                  ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(IzinTetangga data) {
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
              Icons.people,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kpltName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Izin Tetangga',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(data),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IzinTetangga data) {
    final isCompleted = data.isCompleted;
    final statusColor = isCompleted ? AppColors.successColor : Colors.orange;
    final statusText = isCompleted ? 'Selesai' : 'Dalam Proses';
    final statusIcon = isCompleted ? Icons.check_circle : Icons.pending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
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
          const SizedBox(height: 8),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 8),
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

  Widget _buildFileRow(BuildContext context, String label, String filePath) {
    return InkWell(
      onTap: () => _openOrDownloadFile(context, filePath),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.description, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    filePath.split('/').last,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new_rounded, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Future<void> _openOrDownloadFile(BuildContext context, String? pathOrUrl) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dokumen tidak tersedia.')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final localFileName = pathOrUrl.split('/').last;
    final localPath = '${directory.path}/$localFileName';
    final localFile = File(localPath);

    if (await localFile.exists()) {
      await OpenFilex.open(localPath);
    } else {
      _showLoadingDialog(context);
      try {
        final supabase = Supabase.instance.client;
        final fileBytes = await supabase.storage.from('file_storage').download(pathOrUrl);
        Navigator.of(context).pop();

        await localFile.writeAsBytes(fileBytes, flush: true);
        await OpenFilex.open(localPath);
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh file: $e')),
        );
      }
    }
  }
}