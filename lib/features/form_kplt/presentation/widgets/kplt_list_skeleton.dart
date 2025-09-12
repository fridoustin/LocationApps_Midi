import 'package:flutter/material.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_card_skeleton.dart';
import 'package:shimmer/shimmer.dart';

class KpltListSkeleton extends StatelessWidget {
  const KpltListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => const KpltCardSkeleton(),
      ),
    );
  }
}