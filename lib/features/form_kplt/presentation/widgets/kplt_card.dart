import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';

class KpltCard extends StatelessWidget {
  final FormKPLT kplt;
  const KpltCard({super.key, required this.kplt});

  // Helper untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return AppColors.warningColor;
      case 'OK':
        return AppColors.successColor;
      case 'NOK':
        return AppColors.primaryColor;
      case 'Waiting for Forum':
        return AppColors.warningColor;
      case 'Need Input':
        return Color(0xFFD9D9D9);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gabungkan alamat lengkap
    final fullAddress =
        '${kplt.alamat}, Kec. ${kplt.kecamatan}, ${kplt.kabupaten}, ${kplt.provinsi}';
    // Format tanggal
    final formattedDate = DateFormat('dd MMMM yyyy').format(kplt.tanggal);

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
                    kplt.namaLokasi,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Visibility(
                  visible: ['Waiting for Forum', 'In Progress', 'Need Input'].contains(kplt.status),
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
                    color: _getStatusColor(kplt.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // 2. Gunakan Center untuk memusatkan teks
                  child: Center(
                    child: Text(
                      kplt.status,
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