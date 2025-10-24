import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';

abstract class AssignmentRepository {
  // Activity Templates
  Future<List<ActivityTemplate>> getActivityTemplates();
  
  // Assignments
  Future<List<Assignment>> getAssignments({
    AssignmentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Assignment> getAssignmentById(String id);
  Future<Assignment> createAssignment(Assignment assignment, List<String> activityIds);
  Future<Assignment> updateAssignment(Assignment assignment);
  Future<void> deleteAssignment(String id);
  
  // Assignment Activities
  Future<List<AssignmentActivity>> getAssignmentActivities(String assignmentId);
  Future<void> toggleActivityCompletion(String activityId, bool isCompleted);
  
  // Check-in related
  Future<void> checkInActivity(
    String activityId,
    LatLng checkedInLocation,
  );
  Future<void> updateActivityLocation(
    String activityId,
    String? locationName,
    LatLng? location,
    bool requiresCheckin,
    int checkInRadius,
  );
  
  // Tracking
  Future<List<TrackingPoint>> getTrackingHistory(String assignmentId);
  Future<TrackingPoint> addTrackingPoint(TrackingPoint point);
  Future<void> updateAssignmentStatus(String assignmentId, AssignmentStatus status);
}