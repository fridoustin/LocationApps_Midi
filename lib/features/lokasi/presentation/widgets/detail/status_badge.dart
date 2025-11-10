// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class StatusBadge extends StatelessWidget {
  final bool isCompleted;
  final String? completedText;
  final String? inProgressText;

  const StatusBadge({
    super.key,
    required this.isCompleted,
    this.completedText,
    this.inProgressText,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCompleted ? AppColors.successColor : Colors.orange;
    final statusText = isCompleted 
        ? (completedText ?? 'Selesai') 
        : (inProgressText ?? 'Dalam Proses');
    final statusIcon = isCompleted ? Icons.check_circle : Icons.pending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}