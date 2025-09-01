import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';

class ProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final String? avatarUrl;
  final VoidCallback onEditTap;

  const ProfileAvatar({
    super.key,
    this.imageFile,
    this.avatarUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            // 2. TAMPILKAN GAMBAR DARI URL JIKA ADA
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: _buildChild(),
          ),
          Positioned(
            bottom: 0,
            right: -10,
            child: GestureDetector(
              onTap: onEditTap,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menentukan apa yang ditampilkan di dalam CircleAvatar
  Widget? _buildChild() {
    // Prioritas 1: Tampilkan gambar baru yang dipilih pengguna
    if (imageFile != null) {
      return ClipOval(
        child: Image.file(
          imageFile!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    // Prioritas 2: Jika tidak ada gambar baru DAN tidak ada URL, tampilkan ikon default
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return SvgPicture.asset(
        "assets/icons/avatar.svg",
        width: 80,
        height: 80,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryColor,
          BlendMode.srcIn,
        ),
      );
    }
    // Jika ada URL (sudah ditangani backgroundImage), jangan tampilkan apa-apa
    return null;
  }
}

