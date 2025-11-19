// lib/features/penugasan/presentation/widgets/tracking/assignment_list_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';

class AssignmentListSheet extends ConsumerWidget {
  final List<Assignment> assignments;
  final Function(Assignment) onAssignmentTap;

  const AssignmentListSheet({
    super.key,
    required this.assignments,
    required this.onAssignmentTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                return AssignmentListItem(
                  assignment: assignments[index],
                  onTap: () => onAssignmentTap(assignments[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penugasan Aktif',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Pilih untuk melihat lokasi di peta',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}

class AssignmentListItem extends ConsumerWidget {
  final Assignment assignment;
  final VoidCallback onTap;

  const AssignmentListItem({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AssignmentStatusBadge(status: assignment.status),
                      const Spacer(),
                      Icon(Icons.map, size: 18, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (assignment.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      assignment.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('dd MMM').format(assignment.startDate)} - ${DateFormat('dd MMM').format(assignment.endDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      AssignmentActivityCountBadge(
                        assignmentId: assignment.id,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AssignmentActivityCountBadge extends ConsumerWidget {
  final String assignmentId;

  const AssignmentActivityCountBadge({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync =
        ref.watch(assignmentActivitiesProvider(assignmentId));

    return activitiesAsync.when(
      data: (activities) {
        final completedCount = activities.where((a) => a.isCompleted).length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.checklist,
                size: 13,
                color: AppColors.successColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$completedCount/${activities.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class AssignmentStatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const AssignmentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 14, color: _getColor()),
          const SizedBox(width: 4),
          Text(
            _getText(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
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

  IconData _getIcon() {
    switch (status) {
      case AssignmentStatus.pending:
        return Icons.pending;
      case AssignmentStatus.inProgress:
        return Icons.play_circle_outline;
      case AssignmentStatus.completed:
        return Icons.check_circle;
      case AssignmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getText() {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Belum Dikerjakan';
      case AssignmentStatus.inProgress:
        return 'Sedang Dikerjakan';
      case AssignmentStatus.completed:
        return 'Selesai';
      case AssignmentStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}