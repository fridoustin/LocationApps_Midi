import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

class AssignmentInfoSection extends StatelessWidget {
  final Assignment assignment;
  final double progress;
  final int completedCount;
  final int totalCount;

  const AssignmentInfoSection({
    super.key,
    required this.assignment,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(assignment.status),
            ],
          ),
          
          // Description
          if (assignment.description != null) ...[
            const SizedBox(height: 8),
            Text(
              assignment.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Date Info
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('dd MMM').format(assignment.startDate)} - ${DateFormat('dd MMM yyyy').format(assignment.endDate)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Tugas',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$completedCount dari $totalCount Selesai',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryColor
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
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.successColor : AppColors.primaryColor,
              ),
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
        text = 'Belum Mulai';
        break;
      case AssignmentStatus.inProgress:
        bgColor = AppColors.blue.withOpacity(0.1);
        textColor = AppColors.blue;
        text = 'Dikerjakan';
        break;
      case AssignmentStatus.completed:
        bgColor = AppColors.successColor.withOpacity(0.1);
        textColor = AppColors.successColor;
        text = 'Selesai';
        break;
      case AssignmentStatus.cancelled:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Batal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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