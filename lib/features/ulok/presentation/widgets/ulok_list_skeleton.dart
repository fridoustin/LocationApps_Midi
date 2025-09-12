import 'package:flutter/material.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_card_skeleton.dart';
import 'package:shimmer/shimmer.dart';

class UlokListSkeleton extends StatelessWidget {
  const UlokListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        // Jangan biarkan user scroll saat loading
        physics: const NeverScrollableScrollPhysics(), 
        itemCount: 6, // Tampilkan 6 skeleton untuk mengisi layar
        itemBuilder: (context, index) => const UlokCardSkeleton(),
      ),
    );
  }
}