import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

class AssignmentHeaderCard extends StatelessWidget {
  final Assignment assignment;
  final double progress;
  final int completedCount;
  final int totalCount;

  const AssignmentHeaderCard({
    super.key,
    required this.assignment,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    // Logic warna: Jika 100% (1.0) jadi hijau, jika belum jadi merah (primary)
    final isCompleted = progress >= 1.0;
    final progressColor = isCompleted ? AppColors.successColor : AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(assignment.status),
              Text(
                'Deadline: ${DateFormat("dd MMM").format(assignment.endDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            assignment.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          if (assignment.description != null && assignment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assignment.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Progress Bar Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Penyelesaian',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '$completedCount / $totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor, // Warna teks mengikuti status
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              // Warna bar berubah jadi hijau jika full
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AssignmentStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case AssignmentStatus.pending:
        bgColor = AppColors.warningColor.withOpacity(0.1);
        textColor = AppColors.warningColor;
        text = 'Belum Dimulai';
        break;
      case AssignmentStatus.inProgress:
        bgColor = AppColors.blue.withOpacity(0.1);
        textColor = AppColors.blue;
        text = 'Sedang Berjalan';
        break;
      case AssignmentStatus.completed:
        bgColor = AppColors.successColor.withOpacity(0.1);
        textColor = AppColors.successColor;
        text = 'Selesai';
        break;
      case AssignmentStatus.cancelled:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}