import 'package:latlong2/latlong.dart';

class AssignmentActivity {
  final String id;
  final String assignmentId;
  final String activityTemplateId;
  final String activityName;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final String? locationName;
  final LatLng? location;
  final int checkInRadius;
  final bool requiresCheckin;
  final DateTime? checkedInAt;
  final LatLng? checkedInLocation;
  final String? externalLocationId;

  AssignmentActivity({
    required this.id,
    required this.assignmentId,
    required this.activityTemplateId,
    required this.activityName,
    required this.isCompleted,
    this.completedAt,
    this.notes,
    required this.createdAt,
    this.locationName,
    this.location,
    required this.checkInRadius,
    required this.requiresCheckin,
    this.checkedInAt,
    this.checkedInLocation,
    this.externalLocationId
  });

  factory AssignmentActivity.fromMap(Map<String, dynamic> map) {
    LatLng? activityLocation;
    if (map['latitude'] != null && map['longitude'] != null) {
      activityLocation = LatLng(
        (map['latitude'] as num).toDouble(),
        (map['longitude'] as num).toDouble(),
      );
    }
    
    LatLng? checkedInLoc;
    if (map['checked_in_latitude'] != null && map['checked_in_longitude'] != null) {
      checkedInLoc = LatLng(
        (map['checked_in_latitude'] as num).toDouble(),
        (map['checked_in_longitude'] as num).toDouble(),
      );
    }
    
    return AssignmentActivity(
      id: map['id'],
      assignmentId: map['assignment_id'],
      activityTemplateId: map['activity_template_id'],
      activityName: map['activity_name'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      locationName: map['location_name'],
      location: activityLocation,
      checkInRadius: map['check_in_radius'] ?? 100,
      requiresCheckin: map['requires_checkin'] ?? false,
      checkedInAt: map['checked_in_at'] != null
          ? DateTime.parse(map['checked_in_at'])
          : null,
      checkedInLocation: checkedInLoc,
      externalLocationId: map['external_location_id']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'activity_template_id': activityTemplateId,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'location_name': locationName,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'check_in_radius': checkInRadius,
      'requires_checkin': requiresCheckin,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'checked_in_latitude': checkedInLocation?.latitude,
      'checked_in_longitude': checkedInLocation?.longitude,
      'external_location_id': externalLocationId
    };
  }

  AssignmentActivity copyWith({
    String? id,
    String? assignmentId,
    String? activityTemplateId,
    String? activityName,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    DateTime? createdAt,
    String? locationName,
    LatLng? location,
    int? checkInRadius,
    bool? requiresCheckin,
    DateTime? checkedInAt,
    LatLng? checkedInLocation,
    String? externalLocationId
  }) {
    return AssignmentActivity(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      activityTemplateId: activityTemplateId ?? this.activityTemplateId,
      activityName: activityName ?? this.activityName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
      location: location ?? this.location,
      checkInRadius: checkInRadius ?? this.checkInRadius,
      requiresCheckin: requiresCheckin ?? this.requiresCheckin,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInLocation: checkedInLocation ?? this.checkedInLocation,
      externalLocationId: externalLocationId ?? this.externalLocationId
    );
  }
  
  bool canBeCompleted() {
    if (!requiresCheckin) return true;
    return checkedInAt != null;
  }
}