import 'package:latlong2/latlong.dart';

enum AssignmentType { self, fromManager, externalCheck }
enum AssignmentStatus { pending, inProgress, completed, cancelled }

class Assignment {
  final String id;
  final String userId;
  final String? assignedBy;
  final String title;
  final String? description;
  final AssignmentType type;
  final AssignmentStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String? locationName;
  final LatLng? location;
  final int checkInRadius;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.userId,
    this.assignedBy,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.locationName,
    this.location,
    required this.checkInRadius,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    LatLng? latLng;
    if (map['latitude'] != null && map['longitude'] != null) {
      latLng = LatLng(
        (map['latitude'] as num).toDouble(),
        (map['longitude'] as num).toDouble(),
      );
    }

    return Assignment(
      id: map['id'],
      userId: map['user_id'],
      assignedBy: map['assigned_by'],
      title: map['title'],
      description: map['description'],
      type: _parseAssignmentType(map['assignment_type']),
      status: _parseAssignmentStatus(map['status']),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      locationName: map['location_name'],
      location: latLng,
      checkInRadius: map['check_in_radius'] ?? 100,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'assigned_by': assignedBy,
      'title': title,
      'description': description,
      'assignment_type': _assignmentTypeToString(type),
      'status': _assignmentStatusToString(status),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location_name': locationName,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'check_in_radius': checkInRadius,
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  static AssignmentType _parseAssignmentType(String? value) {
    switch (value) {
      case 'self':
        return AssignmentType.self;
      case 'from_manager':
        return AssignmentType.fromManager;
      case 'external_check':
        return AssignmentType.externalCheck;
      default:
        return AssignmentType.self;
    }
  }

  static AssignmentStatus _parseAssignmentStatus(String? value) {
    switch (value) {
      case 'pending':
        return AssignmentStatus.pending;
      case 'in_progress':
        return AssignmentStatus.inProgress;
      case 'completed':
        return AssignmentStatus.completed;
      case 'cancelled':
        return AssignmentStatus.cancelled;
      default:
        return AssignmentStatus.pending;
    }
  }

  static String _assignmentTypeToString(AssignmentType type) {
    switch (type) {
      case AssignmentType.self:
        return 'self';
      case AssignmentType.fromManager:
        return 'from_manager';
      case AssignmentType.externalCheck:
        return 'external_check';
    }
  }

  static String _assignmentStatusToString(AssignmentStatus status) {
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

  Assignment copyWith({
    String? id,
    String? userId,
    String? assignedBy,
    String? title,
    String? description,
    AssignmentType? type,
    AssignmentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? locationName,
    LatLng? location,
    int? checkInRadius,
    DateTime? completedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assignedBy: assignedBy ?? this.assignedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      locationName: locationName ?? this.locationName,
      location: location ?? this.location,
      checkInRadius: checkInRadius ?? this.checkInRadius,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}