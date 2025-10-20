// features/form_kplt/presentation/widgets/kplt_need_input_card.dart

// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';

class KpltNeedInputCard extends ConsumerWidget {
  final FormKPLT kplt;
  
  const KpltNeedInputCard({
    super.key, 
    required this.kplt,
  });

  // --- TAMBAHAN: HELPER UNTUK FORMAT TANGGAL ---
  String _formatLastEdited(DateTime? lastEdited) {
    if (lastEdited == null) return 'Draft tersimpan';
    
    final now = DateTime.now();
    final difference = now.difference(lastEdited);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final day = lastEdited.day.toString().padLeft(2, '0');
      final month = lastEdited.month.toString().padLeft(2, '0');
      return '$day/$month/${lastEdited.year}';
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(kpltDraftsProvider);

    final addressParts = [
      kplt.alamat,
      kplt.kecamatan != null ? 'Kec. ${kplt.kecamatan}' : null,
      kplt.kabupaten,
      kplt.provinsi
    ];
    final fullAddress = addressParts.where((p) => p != null && p.isNotEmpty).join(', ');
    
    final formattedDate = DateFormat('dd MMMM yyyy').format(kplt.tanggal);

    const double outerRadius = 14.0;
    const double innerRadius = 12.0; 
    const double highlightWidth = 5.0;

    return draftsAsync.when(
      data: (drafts) {
        final draft = drafts.firstWhereOrNull((d) => d.ulokId == kplt.ulokId);
        final bool hasDraft = draft != null;

        final highlightColor = hasDraft ? AppColors.blue : AppColors.orange;
        final buttonText = hasDraft ? 'Lanjutkan Pengisian' : 'Isi Form KPLT';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(outerRadius),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.only(left: highlightWidth),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(innerRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kplt.namaLokasi,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fullAddress.isEmpty ? '(Alamat tidak tersedia)' : fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Di Approved : $formattedDate',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // --- TAMBAHAN: TAMPILKAN LAST EDITED JIKA ADA DRAFT ---
                  if (hasDraft) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Last edited: ${_formatLastEdited(draft.lastEdited)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  // --- BATAS TAMBAHAN ---

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final ulokDataForForm = UsulanLokasi(
                            id: kplt.ulokId,
                            namaLokasi: kplt.namaLokasi,
                            alamat: kplt.alamat,
                            kecamatan: kplt.kecamatan,
                            desaKelurahan: kplt.desaKelurahan,
                            kabupaten: kplt.kabupaten,
                            provinsi: kplt.provinsi,
                            status: kplt.status,
                            tanggal: kplt.tanggal,
                            latLong: kplt.latLong,
                            formatStore: kplt.formatStore,
                            bentukObjek: kplt.bentukObjek,
                            alasHak: kplt.alasHak,
                            jumlahLantai: kplt.jumlahLantai,
                            lebarDepan: kplt.lebarDepan,
                            panjang: kplt.panjang,
                            luas: kplt.luas,
                            hargaSewa: kplt.hargaSewa,
                            namaPemilik: kplt.namaPemilik,
                            kontakPemilik: kplt.kontakPemilik,
                            formUlok: kplt.formUlok,
                            approvalIntip: kplt.approvalIntip,
                            tanggalApprovalIntip: kplt.tanggalApprovalIntip,
                            fileIntip: kplt.fileIntip
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KpltFormPage(ulok: ulokDataForForm),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlightColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      // Placeholder saat loading
      loading: () => Container(
        height: 190,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Gagal memuat status draft: $err'),
        ),
      ),
    );
  }
}