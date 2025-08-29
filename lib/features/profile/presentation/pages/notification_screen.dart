import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'ULok Disetujui',
        'subtitle':
            'Usulan Lokasi anda telah disetujui oleh Location Manager, silahkan lengkapi data di form KPLT',
        'time': '10 Menit yang lalu',
        'isRead': false,
      },
      {
        'title': 'ULok Disetujui',
        'subtitle':
            'Usulan Lokasi anda telah disetujui oleh Location Manager, silahkan lengkapi data di form KPLT',
        'time': '5 Hari yang lalu',
        'isRead': false,
      },
      {
        'title': 'ULok Disetujui',
        'subtitle':
            'Usulan Lokasi anda telah disetujui oleh Location Manager, silahkan lengkapi data di form KPLT',
        'time': '2 Bulan yang lalu',
        'isRead': true,
      },
      // Anda bisa menambahkan notifikasi lain di sini
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header yang sama dengan HelpScreen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 75, bottom: 40),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "Notification",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Positioned(
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      "assets/icons/left_arrow.svg",
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Notifikasi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: AppColors.cardColor,
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['subtitle'],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['time'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notification['isRead'])
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
