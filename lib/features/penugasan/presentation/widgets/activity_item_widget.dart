import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';

class ActivityItemWidget extends ConsumerWidget {
  final AssignmentActivity activity;
  final bool isAssignmentCompleted;
  
  final bool isCheckingIn;
  final bool isToggling;
  final Function() onCheckIn;
  final Function(bool) onToggle;

  const ActivityItemWidget({
    super.key,
    required this.activity,
    required this.isAssignmentCompleted,
    required this.isCheckingIn,
    required this.isToggling,
    required this.onCheckIn,
    required this.onToggle,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: activity.isCompleted 
              ? AppColors.successColor.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                isToggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Checkbox(
                      value: activity.isCompleted,
                      activeColor: AppColors.successColor,
                      onChanged: (isAssignmentCompleted || activity.isCompleted) 
                        ? null 
                        : (val) => onToggle(val!),
                    ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (activity.requiresCheckin) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: activity.checkedInAt != null
                                  ? AppColors.successColor
                                  : AppColors.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.checkedInAt != null
                                  ? 'Sudah Check-in'
                                  : 'Perlu Check-in',
                              style: TextStyle(
                                fontSize: 12,
                                color: activity.checkedInAt != null
                                    ? AppColors.successColor
                                    : AppColors.warningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (activity.locationName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.locationName!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
            if (activity.requiresCheckin) ...[
              if (activity.checkedInAt != null)
                _buildInfoRow(
                  icon: Icons.check_circle,
                  text: 'Check-in: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.checkedInAt!)}',
                  color: AppColors.successColor,
                )
              else if (!isAssignmentCompleted)
                ElevatedButton.icon(
                  onPressed: isCheckingIn ? null : onCheckIn,
                  icon: isCheckingIn
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.location_on, size: 18),
                  label: const Text('Check-in'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              const SizedBox(height: 8),
            ],

            // Info Selesai (Waktu DAN Durasi)
            if (activity.isCompleted && activity.completedAt != null) ...[
              _buildInfoRow(
                icon: Icons.task_alt,
                text: 'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.completedAt!)}',
                color: AppColors.primaryColor,
              ),
              if (activity.checkedInAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.timer,
                  text: 'Durasi: ${_formatDuration(activity.completedAt!.difference(activity.checkedInAt!))}',
                  color: Colors.grey[700]!,
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}