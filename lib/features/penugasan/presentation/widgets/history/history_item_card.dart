import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/pages/assignment_detail_page.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';

class HistoryItemCard extends ConsumerWidget {
  final Assignment assignment;
  final bool isLast;

  const HistoryItemCard({
    super.key,
    required this.assignment,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = assignment.status == AssignmentStatus.completed;
    final displayDate = assignment.completedAt ?? assignment.updatedAt;
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(displayDate);
    final dayName = DateFormat('EEEE').format(displayDate);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignmentDetailPage(assignment: assignment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppColors.successColor.withOpacity(0.3)
                  : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(isCompleted: isCompleted),
                ],
              ),

              const SizedBox(height: 8),

              // Day and Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$dayName, $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Period
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.event_note, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Periode: ${DateFormat('dd MMM').format(assignment.startDate)} - ${DateFormat('dd MMM yyyy').format(assignment.endDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Description
              if (assignment.description != null &&
                  assignment.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Activity count
              _ActivityCountBadge(assignmentId: assignment.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;

  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.successColor.withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCompleted ? 'Selesai' : 'Dibatalkan',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCompleted ? AppColors.successColor : Colors.grey[700],
        ),
      ),
    );
  }
}

class _ActivityCountBadge extends ConsumerWidget {
  final String assignmentId;

  const _ActivityCountBadge({required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(assignmentActivitiesProvider(assignmentId));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();

        final completedCount = activities.where((a) => a.isCompleted).length;
        final totalCount = activities.length;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.checklist,
                    size: 16,
                    color: AppColors.successColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$completedCount/$totalCount Aktivitas',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}