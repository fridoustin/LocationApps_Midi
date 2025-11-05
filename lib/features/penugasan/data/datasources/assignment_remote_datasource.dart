import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';

class AssignmentRemoteDataSource {
  final SupabaseClient _supabase;

  AssignmentRemoteDataSource(this._supabase);

  // Activity Templates
  Future<List<ActivityTemplate>> getActivityTemplates() async {
    final response = await _supabase
        .from('activity_templates')
        .select()
        .eq('is_active', true);

    return (response as List)
        .map((json) => ActivityTemplate.fromMap(json))
        .toList();
  }

  // Helper method untuk convert enum ke string
  String _assignmentStatusToString(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 'pending';
      case AssignmentStatus.inProgress:
        return 'in_progress';
      case AssignmentStatus.completed:
        return 'completed';
      case AssignmentStatus.cancelled:
        return 'cancelled';
    }
  }

  // Assignments
  Future<List<Assignment>> getAssignments({
    AssignmentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase
        .from('assignments')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);

    if (status != null) {
      query = query.eq('status', _assignmentStatusToString(status));
    }

    if (startDate != null) {
      query = query.gte('start_date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('end_date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => Assignment.fromMap(json))
        .toList();
  }

  Future<Assignment> getAssignmentById(String id) async {
    final response = await _supabase
        .from('assignments')
        .select()
        .eq('id', id)
        .single();

    return Assignment.fromMap(response);
  }

  Future<Assignment> createAssignment(
    Assignment assignment,
    List<String> activityIds,
  ) async {
    // Insert assignment
    final assignmentData = assignment.toMap();
    assignmentData.remove('id'); // Let database generate ID
    
    final assignmentResponse = await _supabase
        .from('assignments')
        .insert(assignmentData)
        .select()
        .single();

    final newAssignment = Assignment.fromMap(assignmentResponse);

    // Insert assignment activities
    if (activityIds.isNotEmpty) {
      final activitiesData = activityIds.map((activityId) => {
        'assignment_id': newAssignment.id,
        'activity_template_id': activityId,
        'is_completed': false,
      }).toList();

      await _supabase
          .from('assignment_activities')
          .insert(activitiesData);
    }

    return newAssignment;
  }

  Future<Assignment> updateAssignment(Assignment assignment) async {
    final response = await _supabase
        .from('assignments')
        .update(assignment.toMap())
        .eq('id', assignment.id)
        .select()
        .single();

    return Assignment.fromMap(response);
  }

  Future<void> deleteAssignment(String id) async {
    await _supabase
        .from('assignments')
        .delete()
        .eq('id', id);
  }

  // Assignment Activities
  Future<List<AssignmentActivity>> getAssignmentActivities(
    String assignmentId,
  ) async {
    final response = await _supabase
        .from('assignment_activities')
        .select('''
          *,
          activity_template:activity_templates(name)
        ''')
        .eq('assignment_id', assignmentId)
        .order('created_at');

    return (response as List).map((json) {
      final activityName = json['activity_template']?['name'] ?? '';
      json['activity_name'] = activityName;
      return AssignmentActivity.fromMap(json);
    }).toList();
  }

  Future<void> toggleActivityCompletion(
    String activityId,
    bool isCompleted,
  ) async {
    await _supabase
        .from('assignment_activities')
        .update({
          'is_completed': isCompleted,
          'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', activityId);
  }

  Future<void> checkInActivity(
    String activityId,
    LatLng checkedInLocation,
  ) async {
    await _supabase
        .from('assignment_activities')
        .update({
          'checked_in_at': DateTime.now().toIso8601String(),
          'checked_in_latitude': checkedInLocation.latitude,
          'checked_in_longitude': checkedInLocation.longitude,
        })
        .eq('id', activityId);
  }

  Future<void> updateActivityLocation(
    String activityId,
    String? locationName,
    LatLng? location,
    bool requiresCheckin,
    int checkInRadius,
  ) async {
    await _supabase
        .from('assignment_activities')
        .update({
          'location_name': locationName,
          'latitude': location?.latitude,
          'longitude': location?.longitude,
          'requires_checkin': requiresCheckin,
          'check_in_radius': checkInRadius,
        })
        .eq('id', activityId);
  }

  // Tracking
  Future<List<TrackingPoint>> getTrackingHistory(String assignmentId) async {
    final response = await _supabase
        .from('assignment_tracking')
        .select()
        .eq('assignment_id', assignmentId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TrackingPoint.fromMap(json))
        .toList();
  }

  Future<TrackingPoint> addTrackingPoint(TrackingPoint point) async {
    final data = point.toMap();
    data.remove('id'); // Let database generate ID
    
    final response = await _supabase
        .from('assignment_tracking')
        .insert(data)
        .select()
        .single();

    return TrackingPoint.fromMap(response);
  }

  Future<void> updateAssignmentStatus(
    String assignmentId,
    AssignmentStatus status,
  ) async {
    final updates = {
      'status': _assignmentStatusToString(status),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (status == AssignmentStatus.completed) {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }

    await _supabase
        .from('assignments')
        .update(updates)
        .eq('id', assignmentId);
  }
}