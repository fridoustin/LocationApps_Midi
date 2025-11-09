// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_detail_section.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltDetailScreen extends ConsumerWidget {
  final String kpltId;
  const KpltDetailScreen({super.key, required this.kpltId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpltAsyncValue = ref.watch(kpltDetailProvider(kpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: kpltAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(err.toString()),
        data: (kpltData) => _KpltDetailView(kplt: kpltData),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
          ],
        ),
      ),
    );
  }
}

class _KpltDetailView extends StatelessWidget {
  final FormKPLT kplt;
  const _KpltDetailView({required this.kplt});

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return AppColors.secondaryColor;
      case 'OK':
        return AppColors.successColor;
      case 'NOK':
        return AppColors.primaryColor;
      case 'Waiting for Forum':
        return AppColors.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFileRow(BuildContext context, String label, String? filePath) {
    final hasFile = filePath != null && filePath.isNotEmpty;

    return InkWell(
      onTap: hasFile ? () => _openOrDownloadFile(context, filePath) : null,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(kplt.tanggal);
    final latLngParts = kplt.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
      double.tryParse(latLngParts[0]) ?? 0.0,
      double.tryParse(latLngParts[1]) ?? 0.0,
    );
    final fullAddress = [
      kplt.alamat,
      kplt.desaKelurahan,
      kplt.kecamatan.isNotEmpty ? 'Kec. ${kplt.kecamatan}' : '',
      kplt.kabupaten,
      kplt.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    return SingleChildScrollView(
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
                        Icons.store,
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
                            kplt.namaLokasi,
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
                        color: _getStatusColor(kplt.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(kplt.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        kplt.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(kplt.status),
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
              InfoRowWidget(label: "LatLong", value: kplt.latLong ?? "-"),
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
                value1: kplt.formatStore ?? '-',
                label2: "Bentuk Objek",
                value2: kplt.bentukObjek ?? '-',
              ),
              TwoColumnRowWidget(
                label1: "Alas Hak",
                value1: kplt.alasHak ?? '-',
                label2: "Jumlah Lantai",
                value2: kplt.jumlahLantai?.toString() ?? '-',
              ),
              TwoColumnRowWidget(
                label1: "Lebar Depan",
                value1: kplt.lebarDepan != null ? '${kplt.lebarDepan} m' : '-',
                label2: "Panjang",
                value2: kplt.panjang != null ? '${kplt.panjang} m' : '-',
              ),
              TwoColumnRowWidget(
                label1: "Luas",
                value1: kplt.luas != null ? '${kplt.luas} m²' : '-',
                label2: "Harga Sewa",
                value2: kplt.hargaSewa != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(kplt.hargaSewa)
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
                value1: kplt.namaPemilik ?? '-',
                label2: "Kontak Pemilik",
                value2: kplt.kontakPemilik ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Form Ulok (jika ada)
          if (kplt.formUlok != null && kplt.formUlok!.isNotEmpty) ...[
            DetailSectionWidget(
              title: "Form Ulok",
              iconPath: "assets/icons/lampiran.svg",
              children: [
                _buildFileRow(context, "Form Ulok", kplt.formUlok),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Analisa & FPL
          DetailSectionWidget(
            title: "Analisa & FPL",
            iconPath: "assets/icons/analisis.svg",
            children: [
              TwoColumnRowWidget(
                label1: "Karakter Lokasi",
                value1: kplt.karakterLokasi ?? '-',
                label2: "Sosial Ekonomi",
                value2: kplt.sosialEkonomi ?? '-',
              ),
              TwoColumnRowWidget(
                label1: "Skor FPL",
                value1: kplt.skorFpl?.toString() ?? '-',
                label2: "STD",
                value2: kplt.std != null ? kplt.std!.toInt().toString() : '-',
              ),
              TwoColumnRowWidget(
                label1: "APC",
                value1: kplt.apc != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(kplt.apc)
                    : '-',
                label2: "SPD",
                value2: kplt.spd != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(kplt.spd)
                    : '-',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data PE
          DetailSectionWidget(
            title: "Data PE",
            iconPath: "assets/icons/data_store.svg",
            children: [
              TwoColumnRowWidget(
                label1: "PE Status",
                value1: kplt.peStatus ?? '-',
                label2: "PE RAB",
                value2: kplt.peRab != null
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(kplt.peRab)
                    : '-',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dokumen KPLT
          DetailSectionWidget(
            title: "Dokumen KPLT",
            iconPath: "assets/icons/lampiran.svg",
            children: [
              _buildFileRow(context, "PDF Foto", kplt.pdfFoto),
              _buildFileRow(context, "Counting Kompetitor", kplt.countingKompetitor),
              _buildFileRow(context, "PDF Pembanding", kplt.pdfPembanding),
              _buildFileRow(context, "PDF KKS", kplt.pdfKks),
              _buildFileRow(context, "Excel FPL", kplt.excelFpl),
              _buildFileRow(context, "Excel PE", kplt.excelPe),
              _buildFileRow(context, "Video Traffic Siang", kplt.videoTrafficSiang),
              _buildFileRow(context, "Video Traffic Malam", kplt.videoTrafficMalam),
              _buildFileRow(context, "Video 360 Siang", kplt.video360Siang),
              _buildFileRow(context, "Video 360 Malam", kplt.video360Malam),
              _buildFileRow(context, "Peta Coverage", kplt.petaCoverage),
            ],
          ),

          // Data Intip (jika ada)
          if (kplt.approvalIntip != null) ...[
            const SizedBox(height: 16),
            DetailSectionWidget(
              title: "Data Intip",
              iconPath: "assets/icons/analisis.svg",
              children: [
                TwoColumnRowWidget(
                  label1: "Status Intip",
                  value1: kplt.approvalIntip ?? '-',
                  label2: "Tanggal Intip",
                  value2: kplt.tanggalApprovalIntip != null
                      ? DateFormat('dd MMMM yyyy').format(kplt.tanggalApprovalIntip!)
                      : '-',
                ),
                if (kplt.fileIntip != null && kplt.fileIntip!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildFileRow(context, "File Intip", kplt.fileIntip),
                ],
              ],
            ),
          ],

          // Data Ukur (jika ada)
          if (kplt.formUkur != null && kplt.formUkur!.isNotEmpty) ...[
            const SizedBox(height: 16),
            DetailSectionWidget(
              title: "Data Ukur",
              iconPath: "assets/icons/lampiran.svg",
              children: [
                InfoRowWidget(
                  label: "Tanggal Ukur",
                  value: kplt.tanggalUkur != null
                      ? DateFormat('dd MMMM yyyy').format(kplt.tanggalUkur!)
                      : '-',
                ),
                const SizedBox(height: 8),
                _buildFileRow(context, "Form Ukur", kplt.formUkur),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}