// lib/features/home/presentation/widgets/skeletons/homepage_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HaloTextSkeleton extends StatelessWidget {
  const HaloTextSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 150, height: 24),
          SizedBox(height: 8),
          _SkeletonBox(width: 200, height: 24),
        ],
      ),
    );
  }
}

class HomepageSkeleton extends StatelessWidget {
  const HomepageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 50)),
              SizedBox(width: 16),
              Expanded(child: _SkeletonBox(height: 50)),
            ],
          ),
          SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 90)),
              SizedBox(width: 16),
              Expanded(child: _SkeletonBox(height: 90)),
            ],
          ),
          SizedBox(height: 24),

          _SkeletonBox(height: 20, width: 150),
          SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _SkeletonBox(height: 180)),
              SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _SkeletonBox(height: 52),
                    SizedBox(height: 12),
                    _SkeletonBox(height: 52),
                    SizedBox(height: 12),
                    _SkeletonBox(height: 52),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          _SkeletonBox(height: 280),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;

  const _SkeletonBox({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
