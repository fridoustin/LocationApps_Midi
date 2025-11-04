import 'package:flutter/material.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/card_skeleton.dart';
import 'package:shimmer/shimmer.dart';

class CommonListSkeleton extends StatelessWidget {
  const CommonListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => const CommonCardSkeleton(),
      ),
    );
  }
}
