import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';

class AchievementCard extends StatelessWidget {
  final StatisticData data;
  const AchievementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double approvalRate =
        (data.statusUlokTotal > 0)
            ? (data.statusUlokApproved / data.statusUlokTotal) * 100
            : 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.orange,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Excellent Performance!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  "${approvalRate.toStringAsFixed(0)}% approval rate - Keep up the great work!",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
