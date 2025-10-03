// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_edit_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_detail_section.dart';
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
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (kpltData) {
          // Kirim data KPLT ke widget utama
          return _KpltDetailView(kplt: kpltData);
        },
      ),
    );
  }
}

// Widget utama untuk view agar bisa menggunakan helper functions
class _KpltDetailView extends StatelessWidget {
  final FormKPLT kplt;
  const _KpltDetailView({required this.kplt});

  // --- Helper Functions (diambil dari referensi Anda) ---

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
    // Diambil dari kplt_card
    switch (status) {
      case 'In Progress': return AppColors.warningColor;
      case 'OK': return AppColors.successColor;
      case 'NOK': return AppColors.primaryColor;
      case 'Waiting for Forum': return AppColors.warningColor;
      default: return Colors.grey;
    }
  }
  
  // Helper Widget untuk baris dokumen agar tidak duplikasi kode
  Widget _buildDocumentRow(BuildContext context, {required String label, required String? filePath}) {
    return InkWell(
      onTap: filePath != null && filePath.isNotEmpty ? () => _openOrDownloadFile(context, filePath) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.description, color: filePath != null && filePath.isNotEmpty ? AppColors.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: filePath != null && filePath.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: filePath != null && filePath.isNotEmpty ? Colors.grey : Colors.transparent),
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
          // Header Card (Style dari Ulok Detail)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(kplt.namaLokasi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(color: _getStatusColor(kplt.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(kplt.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  SvgPicture.asset("assets/icons/time.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                  const SizedBox(width: 4),
                  Text("Dibuat Pada $formattedDate", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- BAGIAN DATA ULOK ---
          DetailSectionWidget(title: "Data Usulan Lokasi", iconPath: "assets/icons/location.svg", children: [
            InfoRowWidget(label: "Alamat", value: fullAddress),
            InfoRowWidget(label: "LatLong", value: kplt.latLong ?? "-"),
            const SizedBox(height: 12),
            InteractiveMapWidget(position: latLng),
          ]),
          const SizedBox(height: 16),
          DetailSectionWidget(title: "Data Store", iconPath: "assets/icons/data_store.svg", children: [
            TwoColumnRowWidget(label1: "Format Store", value1: kplt.formatStore ?? '-', label2: "Bentuk Objek", value2: kplt.bentukObjek ?? '-'),
            TwoColumnRowWidget(label1: "Alas Hak", value1: kplt.alasHak ?? '-', label2: "Jumlah Lantai", value2: kplt.jumlahLantai?.toString() ?? '-'),
            TwoColumnRowWidget(label1: "Lebar Depan (m)", value1: "${kplt.lebarDepan ?? '-'}", label2: "Panjang (m)", value2: "${kplt.panjang ?? '-'}",),
            TwoColumnRowWidget(label1: "Luas (m2)", value1: "${kplt.luas ?? '-'}", label2: "Harga Sewa", value2: kplt.hargaSewa != null ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(kplt.hargaSewa) : '-',),
          ]),
          const SizedBox(height: 16),
          DetailSectionWidget(title: "Data Pemilik", iconPath: "assets/icons/profile.svg", children: [
            TwoColumnRowWidget(label1: "Nama Pemilik", value1: kplt.namaPemilik ?? '-', label2: "Kontak Pemilik", value2: kplt.kontakPemilik ?? '-'),
          ]),
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
                  const SizedBox(height: 16),
                  const Text(
                    "File Intip:", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54
                    )
                  ),
                  const SizedBox(height: 8),
                  // Logika untuk menampilkan file (sudah ada di helper Anda)
                  // Anda mungkin perlu menambahkan _isImageFile dan _getPublicUrl jika belum ada
                  InkWell(
                    onTap: () => _openOrDownloadFile(context, kplt.fileIntip),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.description, color: AppColors.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              kplt.fileIntip!.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
          if (kplt.formUlok != null && kplt.formUlok!.isNotEmpty) ...[
            const SizedBox(height: 16),
            DetailSectionWidget(
              title: "Form Ulok",
              iconPath: "assets/icons/lampiran.svg",
              children: [
                InkWell(
                  onTap: () => _openOrDownloadFile(context, kplt.formUlok),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            kplt.formUlok!.split('/').last.split('?').first,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // --- BAGIAN DATA KPLT ---
          DetailSectionWidget(title: "Analisa & FPL", iconPath: "assets/icons/analisis.svg", children: [
            TwoColumnRowWidget(label1: "Karakter Lokasi", value1: kplt.karakterLokasi ?? '-', label2: "Sosial Ekonomi", value2: kplt.sosialEkonomi ?? '-'),
            TwoColumnRowWidget(label1: "Skor FPL", value1: kplt.skorFpl?.toString() ?? '-', label2: "STD", value2: kplt.std?.toString() ?? '-'),
            TwoColumnRowWidget(label1: "APC", value1: kplt.apc?.toString() ?? '-', label2: "SPD", value2: kplt.spd?.toString() ?? '-'),
          ]),
          const SizedBox(height: 16),
          DetailSectionWidget(title: "Data PE", iconPath: "assets/icons/data_store.svg", children: [
            TwoColumnRowWidget(label1: "PE Status", value1: kplt.peStatus ?? '-', label2: "PE RAB", value2: kplt.peRab != null ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(kplt.peRab) : '-',),
          ]),
          const SizedBox(height: 16),
          DetailSectionWidget(title: "Dokumen KPLT", iconPath: "assets/icons/lampiran.svg", children: [
            _buildDocumentRow(context, label: "PDF Foto", filePath: kplt.pdfFoto),
            _buildDocumentRow(context, label: "Counting Kompetitor", filePath: kplt.countingKompetitor),
            _buildDocumentRow(context, label: "PDF Pembanding", filePath: kplt.pdfPembanding),
            _buildDocumentRow(context, label: "PDF KKS", filePath: kplt.pdfKks),
            _buildDocumentRow(context, label: "Excel FPL", filePath: kplt.excelFpl),
            _buildDocumentRow(context, label: "Excel PE", filePath: kplt.excelPe),
            _buildDocumentRow(context, label: "PDF Form Ukur", filePath: kplt.pdfFormUkur),
            _buildDocumentRow(context, label: "Video Traffic Siang", filePath: kplt.videoTrafficSiang),
            _buildDocumentRow(context, label: "Video Traffic Malam", filePath: kplt.videoTrafficMalam),
            _buildDocumentRow(context, label: "Video 360 Siang", filePath: kplt.video360Siang),
            _buildDocumentRow(context, label: "Video 360 Malam", filePath: kplt.video360Malam),
            _buildDocumentRow(context, label: "Peta Coverage", filePath: kplt.petaCoverage),
          ]),
          
          const SizedBox(height: 24),
          if (kplt.status == 'In Progress' || kplt.status == 'Waiting for Forum') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KpltEditPage(kplt: kplt),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Edit Data KPLT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ]
        ],
      ),
    );
  }
}