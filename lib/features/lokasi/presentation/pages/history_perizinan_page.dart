// lib/features/lokasi/presentation/pages/history_perizinan_page.dart

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/perizinan.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        data: (historyList) {
          if (historyList.isEmpty) {
            return _buildEmptyState();
          }
          return _buildHistoryList(context, historyList);
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
                Icons.history,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada history perizinan untuk data ini',
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
              onPressed: () => ref.invalidate(historyPerizinanProvider(perizinanId)),
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

  Widget _buildHistoryList(BuildContext context, List<HistoryPerizinan> historyList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Header
          Container(
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
                    Icons.history,
                    color: AppColors.primaryColor,
                    size: 24,
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
                        '${historyList.length} History',
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
          ),
          const SizedBox(height: 16),

          // History Items
          ...historyList.asMap().entries.map((entry) {
            final index = entry.key;
            final history = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index == historyList.length - 1 ? 0 : 16),
              child: _buildHistoryCard(context, history, index + 1),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryPerizinan history, int number) {
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
          // Header with number and date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#$number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(history.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // SPH
          if (history.nominalSph != null || history.tglSph != null) ...[
            _buildSectionTitle('SPH'),
            const SizedBox(height: 8),
            if (history.nominalSph != null)
              _buildInfoRow(
                'Nominal SPH',
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(history.nominalSph),
              ),
            if (history.nominalSph != null && history.tglSph != null)
              const SizedBox(height: 8),
            if (history.tglSph != null)
              _buildInfoRow(
                'Tanggal SPH',
                DateFormat('dd MMMM yyyy').format(history.tglSph!),
              ),
            if (history.fileSph != null) ...[
              const SizedBox(height: 8),
              _buildFileRow(context, 'File SPH', history.fileSph!),
            ],
            const SizedBox(height: 16),
          ],

          // Status Berkas
          if (history.statusBerkas != null || history.tglStBerkas != null) ...[
            _buildSectionTitle('Status Berkas'),
            const SizedBox(height: 8),
            if (history.statusBerkas != null)
              _buildInfoRow('Status', history.statusBerkas!),
            if (history.statusBerkas != null && history.tglStBerkas != null)
              const SizedBox(height: 8),
            if (history.tglStBerkas != null)
              _buildInfoRow(
                'Tanggal ST Berkas',
                DateFormat('dd MMMM yyyy').format(history.tglStBerkas!),
              ),
            if (history.fileBuktiSt != null) ...[
              const SizedBox(height: 8),
              _buildFileRow(context, 'File Bukti ST', history.fileBuktiSt!),
            ],
            const SizedBox(height: 16),
          ],

          // Gambar Denah
          if (history.statusGambarDenah != null || history.tglGambarDenah != null) ...[
            _buildSectionTitle('Gambar Denah'),
            const SizedBox(height: 8),
            if (history.statusGambarDenah != null)
              _buildInfoRow('Status', history.statusGambarDenah!),
            if (history.statusGambarDenah != null && history.tglGambarDenah != null)
              const SizedBox(height: 8),
            if (history.tglGambarDenah != null)
              _buildInfoRow(
                'Tanggal',
                DateFormat('dd MMMM yyyy').format(history.tglGambarDenah!),
              ),
            if (history.fileDenah != null) ...[
              const SizedBox(height: 8),
              _buildFileRow(context, 'File Denah', history.fileDenah!),
            ],
            const SizedBox(height: 16),
          ],

          // OSS
          if (history.oss != null || history.tglOss != null) ...[
            _buildSectionTitle('OSS'),
            const SizedBox(height: 8),
            if (history.oss != null)
              _buildInfoRow('OSS', history.oss!),
            if (history.oss != null && history.tglOss != null)
              const SizedBox(height: 8),
            if (history.tglOss != null)
              _buildInfoRow(
                'Tanggal OSS',
                DateFormat('dd MMMM yyyy').format(history.tglOss!),
              ),
            const SizedBox(height: 16),
          ],

          // SPK
          if (history.statusSpk != null || history.tglSpk != null) ...[
            _buildSectionTitle('SPK'),
            const SizedBox(height: 8),
            if (history.statusSpk != null)
              _buildInfoRow('Status SPK', history.statusSpk!),
            if (history.statusSpk != null && history.tglSpk != null)
              const SizedBox(height: 8),
            if (history.tglSpk != null)
              _buildInfoRow(
                'Tanggal SPK',
                DateFormat('dd MMMM yyyy').format(history.tglSpk!),
              ),
            if (history.fileSpk != null) ...[
              const SizedBox(height: 8),
              _buildFileRow(context, 'File SPK', history.fileSpk!),
            ],
            const SizedBox(height: 16),
          ],

          // Rekomendasi Notaris
          if (history.rekomNotarisVendor != null || history.tglRekomNotaris != null) ...[
            _buildSectionTitle('Rekomendasi Notaris'),
            const SizedBox(height: 8),
            if (history.rekomNotarisVendor != null)
              _buildInfoRow('Vendor', history.rekomNotarisVendor!),
            if (history.rekomNotarisVendor != null && history.tglRekomNotaris != null)
              const SizedBox(height: 8),
            if (history.tglRekomNotaris != null)
              _buildInfoRow(
                'Tanggal',
                DateFormat('dd MMMM yyyy').format(history.tglRekomNotaris!),
              ),
            if (history.fileRekomNotaris != null) ...[
              const SizedBox(height: 8),
              _buildFileRow(context, 'File Rekomendasi', history.fileRekomNotaris!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.description, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    filePath.split('/').last,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new_rounded, color: Colors.grey[600], size: 18),
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