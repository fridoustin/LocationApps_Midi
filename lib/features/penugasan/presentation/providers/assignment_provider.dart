// lib/features/penugasan/presentation/providers/assignment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/penugasan/data/datasources/assignment_remote_datasource.dart';
import 'package:midi_location/features/penugasan/data/repositories/assignment_repository_impl.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/domain/repositories/assignment_repository.dart';

// Datasource & Repository
final assignmentRemoteDataSourceProvider = Provider<AssignmentRemoteDataSource>((ref) {
  return AssignmentRemoteDataSource(ref.watch(supabaseClientProvider));
});

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepositoryImpl(ref.watch(assignmentRemoteDataSourceProvider));
});

// Activity Templates
final activityTemplatesProvider = FutureProvider<List<ActivityTemplate>>((ref) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getActivityTemplates();
});

// Tab Provider (0 = Tracking, 1 = Assignment, 2 = History)
final penugasanTabProvider = StateProvider<int>((ref) => 1);

// Assignments by Status
final pendingAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getAssignments(status: AssignmentStatus.pending);
});

final inProgressAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getAssignments(status: AssignmentStatus.inProgress);
});

final completedAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getAssignments(status: AssignmentStatus.completed);
});

// All assignments (untuk tracking map)
final allAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getAssignments();
});

// Assignment Activities
final assignmentActivitiesProvider = 
    FutureProvider.autoDispose.family<List<AssignmentActivity>, String>((ref, assignmentId) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getAssignmentActivities(assignmentId);
});

// Tracking History
final trackingHistoryProvider = 
    FutureProvider.autoDispose.family<List<TrackingPoint>, String>((ref, assignmentId) async {
  final repository = ref.watch(assignmentRepositoryProvider);
  return await repository.getTrackingHistory(assignmentId);
});

// Selected Assignment (untuk detail view)
final selectedAssignmentProvider = StateProvider<Assignment?>((ref) => null);