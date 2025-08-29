// lib/core/utils/show_error_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart'; // Import package svg

Future<void> showErrorDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        // Kita akan mengatur konten utama di 'content'
        // untuk kontrol layout yang lebih baik.
        title: const SizedBox.shrink(), // Kosongkan title bawaan
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          children: [
            // 1. Tampilkan gambar SVG
            SvgPicture.asset(
              'assets/icons/error.svg', // Sesuaikan path jika perlu
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 20),

            // 2. Tampilkan judul "Login Gagal"
            const Text(
              'Login Gagal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 3. Tampilkan pesan error
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center, // Pusatkan actions
        actionsPadding: const EdgeInsets.only(bottom: 20),
        actions: <Widget>[
          // 4. Tombol OK di tengah
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.cardColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}