import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';

class UlokCard extends StatelessWidget {
  final UsulanLokasi ulok;
  const UlokCard({super.key, required this.ulok});

  // Helper untuk mendapatkan warna status
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
    // Gabungkan alamat lengkap
    final fullAddress =
        '${ulok.alamat}, Kec. ${ulok.kecamatan}, ${ulok.kabupaten}, ${ulok.provinsi}';
    // Format tanggal
    final formattedDate = DateFormat('dd MMMM yyyy').format(ulok.tanggal);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    ulok.namaLokasi,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Visibility(
                  visible: ulok.status == 'In Progress',
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: IconButton(
                    onPressed: () {
                      // Logika untuk edit
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/editulok.svg', // Path ke SVG Anda
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            Text(fullAddress, style: TextStyle(color: Colors.grey[700], height: 1.4)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // 1. Berikan lebar yang tetap
                  width: 110, 
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ulok.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // 2. Gunakan Center untuk memusatkan teks
                  child: Center(
                    child: Text(
                      ulok.status,
                      style: const TextStyle(
                          color: AppColors.cardColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Text(formattedDate, 
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}