import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_detail_screen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';

class UlokCard extends StatelessWidget {
  final UsulanLokasi ulok;
  const UlokCard({super.key, required this.ulok});

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
    final fullAddress =
        '${ulok.alamat}, ${ulok.desaKelurahan}, Kec. ${ulok.kecamatan}, ${ulok.kabupaten}, ${ulok.provinsi}';

    final formattedDate = DateFormat('dd MMMM yyyy').format(ulok.tanggal);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UlokDetailPage(ulok: ulok)),
        );
      },
      child: Card(
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: ulok.status == 'In Progress',
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: IconButton(
                      onPressed: () {
                        final initialState = UlokFormState.fromUsulanLokasi(ulok);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UlokFormPage(initialState: initialState)),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/editulok.svg',
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

              Text(
                fullAddress,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ulok.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        ulok.status,
                        style: const TextStyle(
                          color: AppColors.cardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
