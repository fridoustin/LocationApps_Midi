// lib/features/home/presentation/pages/help_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> faqItems = [
    {
      'question': 'Kenapa lokasi saya tidak sesuai?',
      'answer':
          'Pastikan layanan lokasi pada perangkat Anda aktif dan aplikasi memiliki izin untuk mengaksesnya. Coba muat ulang halaman atau restart aplikasi jika masalah berlanjut.',
    },
    {
      'question': 'Bagaimana cara memperbarui data profil?',
      'answer':
          'Anda dapat memperbarui informasi pribadi melalui halaman profil. Tekan ikon edit di bagian "Personal Information" untuk mengubah data Anda.',
    },
    {
      'question': 'Apakah saya bisa menerima notifikasi?',
      'answer':
          'Ya, aplikasi ini mendukung notifikasi. Pastikan Anda memberikan izin notifikasi di pengaturan perangkat Anda untuk menerima pembaruan penting.',
    },
    {
      'question': 'Bagaimana jika ingin ganti kata sandi?',
      'answer':
          'Fitur ganti kata sandi saat ini belum tersedia di dalam aplikasi. Silakan hubungi admin atau tim support untuk bantuan lebih lanjut terkait keamanan akun.',
    },
  ];

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mu.co.id',
      queryParameters: {'subject': 'Bantuan Aplikasi Midi Location'},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi email.')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+6281212341234');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka aplikasi telepon.'),
          ),
        );
      }
    }
  }

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
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                    (faq) => FaqItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
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
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _launchEmail,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor
                                      .withOpacity(0.1),
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
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        InkWell(
                          onTap: _launchPhone,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor
                                      .withOpacity(0.1),
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

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        onExpansionChanged: (bool expanded) {
          setState(() => _isExpanded = expanded);
        },
        title: Text(
          widget.question,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _isExpanded ? AppColors.primaryColor : Colors.black87,
          ),
        ),

        trailing: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: _isExpanded ? AppColors.primaryColor : Colors.grey,
          ),
        ),

        shape: const Border(),
        collapsedShape: const Border(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.answer,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.black87, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
