import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPlaceholder(width: 150, height: 24),
            buildPlaceholder(width: 200),
            const SizedBox(height: 16),
            buildPlaceholder(width: double.infinity, height: 40),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: buildPlaceholder(height: 80)),
                const SizedBox(width: 16),
                Expanded(child: buildPlaceholder(height: 80)),
              ],
            ),
            const SizedBox(height: 16),
            buildPlaceholder(height: 200),
            const SizedBox(height: 16),
            buildPlaceholder(height: 200),
          ],
        ),
      ),
    );
  }
}