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

    String dateLabel;
    switch (ulok.status) {
      case 'OK':
        dateLabel = 'Approved on';
        break;
      case 'NOK':
        dateLabel = 'Rejected on';
        break;
      default:
        dateLabel = 'Created on';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UlokDetailPage(ulokId: ulok.id)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      elevation: 0,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                      fullAddress,
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
                    '$dateLabel : $formattedDate',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
