import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HaloTextSkeleton extends StatelessWidget {
  const HaloTextSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildPlaceholder({double? width, double height = 16}) {
      return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPlaceholder(width: 150, height: 24),
          buildPlaceholder(width: 200),
        ],
      ),
    );
  }
}