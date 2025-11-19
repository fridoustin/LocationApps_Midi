import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/activity_item_widget.dart';

class AssignmentActivityList extends StatelessWidget {
  final AsyncValue<List<AssignmentActivity>> activitiesAsync;
  final Assignment currentAssignment;
  final String? checkingInActivityId;
  final String? togglingActivityId;
  final Function(AssignmentActivity) onCheckIn;
  final Function(AssignmentActivity, bool) onToggle;

  const AssignmentActivityList({
    super.key,
    required this.activitiesAsync,
    required this.currentAssignment,
    required this.checkingInActivityId,
    required this.togglingActivityId,
    required this.onCheckIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Text('Belum ada aktivitas');
        }

        return Column(
          children: activities.map((activity) {
            return ActivityItemWidget(
              activity: activity,
              isAssignmentCompleted:
                  currentAssignment.status == AssignmentStatus.completed ||
                      currentAssignment.status == AssignmentStatus.cancelled,
              isCheckingIn: checkingInActivityId == activity.id,
              isToggling: togglingActivityId == activity.id,
              onCheckIn: () => onCheckIn(activity),
              onToggle: (value) => onToggle(activity, value),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
