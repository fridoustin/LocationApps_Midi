import 'package:flutter/material.dart';

class CommonCardSkeleton extends StatelessWidget {
  const CommonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildPlaceholder({double? width, double height = 14, double? radius}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(radius ?? 8),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: buildPlaceholder(height: 20)),
              const SizedBox(width: 16),
              buildPlaceholder(width: 24, height: 48),
            ],
          ),
          const SizedBox(height: 4),
          buildPlaceholder(width: MediaQuery.of(context).size.width * 0.7),
          const SizedBox(height: 8),
          buildPlaceholder(width: MediaQuery.of(context).size.width * 0.5),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildPlaceholder(width: 110, height: 30, radius: 8),
              buildPlaceholder(width: 100, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
