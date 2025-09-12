import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ToggleSwitchSkeleton extends StatelessWidget {
  const ToggleSwitchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 40, // Sesuaikan dengan tinggi toggle Anda
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Sesuaikan dengan radius toggle Anda
        ),
      ),
    );
  }
}