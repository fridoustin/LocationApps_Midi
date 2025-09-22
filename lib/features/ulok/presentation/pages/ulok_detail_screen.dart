import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_edit_page.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_detail_section.dart';

class UlokDetailPage extends StatelessWidget {
  final UsulanLokasi ulok;
  const UlokDetailPage({super.key, required this.ulok});
  static const String route = '/ulok/detail';

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
        title: 'ULOK Detail',
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
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(ulok.namaLokasi,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ulok.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ulok.status,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/time.svg",
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Dibuat Pada $formattedDate",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ]
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            DetailSectionWidget(
              title: "Data Usulan Lokasi",
              iconPath: "assets/icons/location.svg",
              children: [
                InfoRowWidget(label: "Alamat", value: fullAddress),
                InfoRowWidget(label: "LatLong", value: ulok.latLong ?? "-"),
                const SizedBox(height: 12),
                InteractiveMapWidget(position: latLng,),
              ],
            ),
            const SizedBox(height: 16),

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
                  label1: "Lebar Depan (m)",
                  value1: "${ulok.lebarDepan ?? '-'}",
                  label2: "Panjang (m)",
                  value2: "${ulok.panjang ?? '-'}",
                ),
                TwoColumnRowWidget(
                  label1: "Luas (m2)",
                  value1: "${ulok.luas ?? '-'}",
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
            const SizedBox(height: 24),
            
            if (ulok.status == 'In Progress') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UlokEditPage(ulok: ulok))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Edit Data Ulok",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

