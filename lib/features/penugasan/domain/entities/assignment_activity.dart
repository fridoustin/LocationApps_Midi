class AssignmentActivity {
  final String id;
  final String assignmentId;
  final String activityTemplateId;
  final String activityName; 
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;

  AssignmentActivity({
    required this.id,
    required this.assignmentId,
    required this.activityTemplateId,
    required this.activityName,
    required this.isCompleted,
    this.completedAt,
    this.notes,
    required this.createdAt,
  });

  factory AssignmentActivity.fromMap(Map<String, dynamic> map) {
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
    );
  }
}