// lib/features/penugasan/data/repositories/assignment_repository_impl.dart

import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/penugasan/data/datasources/assignment_remote_datasource.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/domain/repositories/assignment_repository.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentRemoteDataSource _remoteDataSource;

  AssignmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ActivityTemplate>> getActivityTemplates() async {
    return await _remoteDataSource.getActivityTemplates();
  }

  @override
  Future<List<Assignment>> getAssignments({
    AssignmentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _remoteDataSource.getAssignments(
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Assignment> getAssignmentById(String id) async {
    return await _remoteDataSource.getAssignmentById(id);
  }

  @override
  Future<Assignment> createAssignment(
    Assignment assignment,
    List<String> activityIds,
  ) async {
    return await _remoteDataSource.createAssignment(assignment, activityIds);
  }

  @override
  Future<Assignment> updateAssignment(Assignment assignment) async {
    return await _remoteDataSource.updateAssignment(assignment);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await _remoteDataSource.deleteAssignment(id);
  }

  @override
  Future<List<AssignmentActivity>> getAssignmentActivities(
    String assignmentId,
  ) async {
    return await _remoteDataSource.getAssignmentActivities(assignmentId);
  }

  @override
  Future<void> toggleActivityCompletion(
    String activityId,
    bool isCompleted,
  ) async {
    await _remoteDataSource.toggleActivityCompletion(activityId, isCompleted);
  }

  @override
  Future<void> checkInActivity(
    String activityId,
    LatLng checkedInLocation,
  ) async {
    await _remoteDataSource.checkInActivity(activityId, checkedInLocation);
  }

  @override
  Future<void> updateActivityLocation(
    String activityId,
    String? locationName,
    LatLng? location,
    bool requiresCheckin,
  ) async {
    await _remoteDataSource.updateActivityLocation(
      activityId,
      locationName,
      location,
      requiresCheckin,
    );
  }

  @override
  Future<List<TrackingPoint>> getTrackingHistory(String assignmentId) async {
    return await _remoteDataSource.getTrackingHistory(assignmentId);
  }

  @override
  Future<TrackingPoint> addTrackingPoint(TrackingPoint point) async {
    return await _remoteDataSource.addTrackingPoint(point);
  }

  @override
  Future<void> updateAssignmentStatus(
    String assignmentId,
    AssignmentStatus status,
  ) async {
    await _remoteDataSource.updateAssignmentStatus(assignmentId, status);
  }
}