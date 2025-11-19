import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class AssignmentFormHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const AssignmentFormHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}