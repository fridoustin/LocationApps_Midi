import 'package:flutter/material.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_card_skeleton.dart';
import 'package:shimmer/shimmer.dart';

class KpltListSkeleton extends StatelessWidget {
  const KpltListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(5, (index) { // Tampilkan 5 skeleton
            return const KpltCardSkeleton();
          }),
        ),
      ),
    );
  }
}