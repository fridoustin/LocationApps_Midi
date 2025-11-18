import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/utils/date_formatter.dart';

class HistoryCardHeader extends StatelessWidget {
  final int number;
  final DateTime createdAt;

  const HistoryCardHeader({
    super.key,
    required this.number,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '#$number',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            DateFormatter.formatDateTime(createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}