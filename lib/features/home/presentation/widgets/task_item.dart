import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

class TaskItem extends StatelessWidget {
  final Assignment assignment;
  const TaskItem({super.key, required this.assignment});

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.warningColor;
      case AssignmentStatus.inProgress:
        return AppColors.cardBlue;
      case AssignmentStatus.completed:
        return AppColors.successColor;
      case AssignmentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Belum Dikerjakan';
      case AssignmentStatus.inProgress:
        return 'Sedang Dikerjakan';
      case AssignmentStatus.completed:
        return 'Selesai';
      case AssignmentStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'N/A';
    }
  }

  String _formatPeriod(DateTime start, DateTime end) {
    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(assignment.status);
    final statusText = _getStatusText(assignment.status);
    final periodText = _formatPeriod(assignment.startDate, assignment.endDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // (Judul & Periode)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      periodText,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 3. Badge Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
