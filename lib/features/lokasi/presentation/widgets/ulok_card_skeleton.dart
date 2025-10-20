import 'package:flutter/material.dart';

class UlokCardSkeleton extends StatelessWidget {
  const UlokCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper untuk membuat kotak abu-abu placeholder
    Widget buildPlaceholder({double? width, double height = 14, double? radius}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // Warna dasar harus ada agar shimmer terlihat
          borderRadius: BorderRadius.circular(radius ?? 8),
        ),
      );
    }

    return Container(
      // Meniru margin dari Card di UlokCard
      margin: const EdgeInsets.only(bottom: 16),
      // Meniru padding dari Padding di UlokCard
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Meniru shape dari Card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meniru baris Judul dan Ikon Edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder untuk judul yang bisa memanjang
              Expanded(child: buildPlaceholder(height: 20)),
              const SizedBox(width: 16),
              // Placeholder untuk ruang IconButton
              buildPlaceholder(width: 24, height: 48), // Tinggi 48 meniru area sentuh IconButton
            ],
          ),

          // Meniru Alamat (kita buat 2 baris untuk simulasi alamat panjang)
          const SizedBox(height: 4),
          buildPlaceholder(width: MediaQuery.of(context).size.width * 0.7),
          const SizedBox(height: 8),
          buildPlaceholder(width: MediaQuery.of(context).size.width * 0.5),

          const SizedBox(height: 16),

          // Meniru baris Status dan Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder untuk badge status
              buildPlaceholder(width: 110, height: 30, radius: 8),
              // Placeholder untuk tanggal
              buildPlaceholder(width: 100, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}