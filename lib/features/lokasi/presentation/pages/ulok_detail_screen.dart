// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_detail_section.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UlokDetailPage extends StatelessWidget {
  final UsulanLokasi ulok;
  const UlokDetailPage({super.key, required this.ulok});
  static const String route = '/ulok/detail';

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

  Future<void> _openOrDownloadFile(BuildContext context, String? pathOrUrl, String ulokId) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dokumen tidak tersedia.')),
      );
      return;
    }

    String relativePath;
    if (pathOrUrl.startsWith('http')) {
      try {
        final publicIndex = pathOrUrl.indexOf('/public/') + '/public/'.length;
        final bucketAndPath = pathOrUrl.substring(publicIndex);
        relativePath = bucketAndPath.substring(bucketAndPath.indexOf('/') + 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format URL lama tidak valid.')),
        );
        return;
      }
    } else {
      relativePath = pathOrUrl;
    }

    final directory = await getApplicationDocumentsDirectory();
    final localFileName = relativePath.split('/').last;
    final localPath = '${directory.path}/$localFileName';
    final localFile = File(localPath);

    if (await localFile.exists()) {
      await OpenFilex.open(localPath);
    } else {
      _showLoadingDialog(context);
      try {
        final supabase = Supabase.instance.client;
        final fileBytes = await supabase.storage.from('file_storage').download(relativePath);
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return AppColors.warningColor;
      case 'OK':
        return AppColors.successColor;
      case 'NOK':
        return AppColors.primaryColor;
      default:
        return Colors.grey;
    }
  }

  bool _isImageFile(String? filePath) {
    if (filePath == null) return false;
    final lowercasedPath = filePath.toLowerCase();
    return lowercasedPath.endsWith('.png') ||
        lowercasedPath.endsWith('.jpg') ||
        lowercasedPath.endsWith('.jpeg');
  }

  String _getPublicUrl(String filePath) {
    return Supabase.instance.client.storage.from('file_storage').getPublicUrl(filePath);
  }

  Widget _buildFileRow(BuildContext context, String label, String? filePath, String ulokId) {
    final hasFile = filePath != null && filePath.isNotEmpty;
    final isImage = _isImageFile(filePath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImage) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _getPublicUrl(filePath!),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    color: AppColors.primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat gambar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          InkWell(
            onTap: hasFile ? () => _openOrDownloadFile(context, filePath, ulokId) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: hasFile ? Colors.grey[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasFile ? Colors.grey[200]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: hasFile ? AppColors.primaryColor : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: hasFile ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (hasFile)
                    Icon(Icons.open_in_new_rounded, color: Colors.grey[600], size: 18)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Tidak Ada',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(ulok.tanggal);
    final latLngParts = ulok.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
      double.tryParse(latLngParts[0]) ?? 0.0,
      double.tryParse(latLngParts[1]) ?? 0.0,
    );

    final fullAddress = [
      ulok.alamat,
      ulok.desaKelurahan,
      ulok.kecamatan.isNotEmpty ? 'Kec. ${ulok.kecamatan}' : '',
      ulok.kabupaten,
      ulok.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Usulan Lokasi',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card - Modern Design
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on,
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
                              ulok.namaLokasi,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Dibuat $formattedDate",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ulok.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(ulok.status).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          ulok.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(ulok.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data Usulan Lokasi
            DetailSectionWidget(
              title: "Data Usulan Lokasi",
              iconPath: "assets/icons/location.svg",
              children: [
                InfoRowWidget(label: "Alamat", value: fullAddress),
                InfoRowWidget(label: "LatLong", value: ulok.latLong ?? "-"),
                const SizedBox(height: 12),
                InteractiveMapWidget(position: latLng),
              ],
            ),
            const SizedBox(height: 16),

            // Data Store
            DetailSectionWidget(
              title: "Data Store",
              iconPath: "assets/icons/data_store.svg",
              children: [
                TwoColumnRowWidget(
                  label1: "Format Store",
                  value1: ulok.formatStore ?? '-',
                  label2: "Bentuk Objek",
                  value2: ulok.bentukObjek ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Alas Hak",
                  value1: ulok.alasHak ?? '-',
                  label2: "Jumlah Lantai",
                  value2: ulok.jumlahLantai?.toString() ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Lebar Depan",
                  value1: ulok.lebarDepan != null ? '${ulok.lebarDepan} m' : '-',
                  label2: "Panjang",
                  value2: ulok.panjang != null ? '${ulok.panjang} m' : '-',
                ),
                TwoColumnRowWidget(
                  label1: "Luas",
                  value1: ulok.luas != null ? '${ulok.luas} m²' : '-',
                  label2: "Harga Sewa",
                  value2: ulok.hargaSewa != null
                      ? NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(ulok.hargaSewa)
                      : '-',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Pemilik
            DetailSectionWidget(
              title: "Data Pemilik",
              iconPath: "assets/icons/profile.svg",
              children: [
                TwoColumnRowWidget(
                  label1: "Nama Pemilik",
                  value1: ulok.namaPemilik ?? '-',
                  label2: "Kontak Pemilik",
                  value2: ulok.kontakPemilik ?? '-',
                ),
              ],
            ),

            // Data Intip (jika ada)
            if (ulok.approvalIntip != null) ...[
              const SizedBox(height: 16),
              DetailSectionWidget(
                title: "Data Intip",
                iconPath: "assets/icons/analisis.svg",
                children: [
                  TwoColumnRowWidget(
                    label1: "Status Intip",
                    value1: ulok.approvalIntip ?? '-',
                    label2: "Tanggal Intip",
                    value2: ulok.tanggalApprovalIntip != null
                        ? DateFormat('dd MMMM yyyy').format(ulok.tanggalApprovalIntip!)
                        : '-',
                  ),
                  if (ulok.fileIntip != null && ulok.fileIntip!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildFileRow(context, "File Intip", ulok.fileIntip, ulok.id),
                  ],
                ],
              ),
            ],

            // Form Ulok (jika ada)
            if (ulok.formUlok != null && ulok.formUlok!.isNotEmpty) ...[
              const SizedBox(height: 16),
              DetailSectionWidget(
                title: "Form Ulok",
                iconPath: "assets/icons/lampiran.svg",
                children: [
                  _buildFileRow(context, "Form Ulok", ulok.formUlok, ulok.id),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Edit Button (jika status In Progress)
            if (ulok.status == 'In Progress') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final initialState = UlokFormState.fromUsulanLokasi(ulok);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UlokFormPage(initialState: initialState),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text(
                    "Edit Data Usulan Lokasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}