import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

/// Section untuk menampilkan informasi assignment
class AssignmentInfoSection extends StatelessWidget {
  final Assignment assignment;

  const AssignmentInfoSection({
    super.key,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          assignment.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Description
        if (assignment.description != null) ...[
          const SizedBox(height: 8),
          Text(
            assignment.description!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Info Cards
        _InfoCard(
          icon: Icons.calendar_today,
          label: 'Periode',
          value:
              '${DateFormat('dd MMM yyyy').format(assignment.startDate)} - '
              '${DateFormat('dd MMM yyyy').format(assignment.endDate)}',
        ),

        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.info_outline,
          label: 'Status',
          value: _getStatusText(assignment.status),
          valueColor: _getStatusColor(assignment.status),
        ),
      ],
    );
  }

  String _getStatusText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Belum Dikerjakan';
      case AssignmentStatus.inProgress:
        return 'Sedang Dikerjakan';
      case AssignmentStatus.completed:
        return 'Sudah Selesai';
      case AssignmentStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.warningColor;
      case AssignmentStatus.inProgress:
        return AppColors.blue;
      case AssignmentStatus.completed:
        return AppColors.successColor;
      case AssignmentStatus.cancelled:
        return Colors.grey;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}