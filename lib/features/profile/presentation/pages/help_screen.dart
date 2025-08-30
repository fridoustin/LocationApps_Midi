import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> faqItems = [
    {
      'question': 'Kenapa lokasi saya tidak sesuai?',
      'answer': 'Pastikan layanan lokasi pada perangkat Anda aktif dan aplikasi memiliki izin untuk mengaksesnya. Coba muat ulang halaman atau restart aplikasi jika masalah berlanjut.',
    },
    {
      'question': 'Bagaimana cara memperbarui data profil?',
      'answer': 'Anda dapat memperbarui informasi pribadi melalui halaman profil. Tekan ikon edit di bagian "Personal Information" untuk mengubah data Anda.',
    },
    {
      'question': 'Apakah saya bisa menerima notifikasi?',
      'answer': 'Ya, aplikasi ini mendukung notifikasi. Pastikan Anda memberikan izin notifikasi di pengaturan perangkat Anda untuk menerima pembaruan penting.',
    },
    {
      'question': 'Bagaimana jika ingin ganti kata sandi?',
      'answer': 'Fitur ganti kata sandi saat ini belum tersedia di dalam aplikasi. Silakan hubungi admin atau tim support untuk bantuan lebih lanjut terkait keamanan akun.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Help',
        showNotificationButton: false, 
        leadingWidget: IconButton( 
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Pertanyaan Umum (FAQ):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ...faqItems.map(
                    (faq) => Card(
                      color: AppColors.cardColor,
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq['question']!,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                faq['answer']!,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kontak Bantuan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: AppColors.cardColor,
                    margin: EdgeInsets.zero,
                    elevation: 1,
                    clipBehavior: Clip.antiAlias, // Agar InkWell tidak keluar dari border radius
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Baris untuk Email
                        InkWell(
                          onTap: () {
                            // TODO: Tambahkan logika untuk membuka aplikasi email
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                                  child: SvgPicture.asset(
                                    "assets/icons/email.svg",
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'support@mu.co.id',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Pemisah antar item
                        const Divider(height: 1, indent: 16, endIndent: 16),

                        // Baris untuk Telepon
                        InkWell(
                          onTap: () {
                            // TODO: Tambahkan logika untuk membuka aplikasi telepon
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                                  child: SvgPicture.asset(
                                    "assets/icons/phone.svg",
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    '+62 812 1234 1234',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}