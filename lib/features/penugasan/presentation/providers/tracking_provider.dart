import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_marker.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';

final trackingActivitiesProvider = FutureProvider.autoDispose
    .family<List<ActivityMarkerData>, List<Assignment>>((ref, assignments) async {
  final List<ActivityMarkerData> result = [];

  for (final assignment in assignments) {
    try {
      final activities = await ref.read(
        assignmentActivitiesProvider(assignment.id).future,
      );

      for (final activity in activities) {
        if (activity.location != null) {
          result.add(ActivityMarkerData(
            activity: activity,
            assignment: assignment,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching activities for ${assignment.id}: $e');
    }
  }

  return result;
});

final activeAssignmentsProvider = Provider.autoDispose<List<Assignment>>((ref) {
  final allAssignmentsAsync = ref.watch(allAssignmentsProvider);

  return allAssignmentsAsync.when(
    data: (assignments) => assignments
        .where((a) =>
            a.type != AssignmentType.self &&
            (a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.inProgress))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    loading: () => [],
    error: (_, __) => [],
  );
});