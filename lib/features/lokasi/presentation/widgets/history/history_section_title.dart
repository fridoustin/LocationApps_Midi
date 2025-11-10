import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class HistorySectionTitle extends StatelessWidget {
  final String title;

  const HistorySectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}