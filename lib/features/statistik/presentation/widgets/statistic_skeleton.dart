import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class StatisticsLoadingSkeleton extends StatelessWidget {
  const StatisticsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}
