class ProgressStep {
  final String id;
  final String kpltId;
  final String title;
  final String? description;
  final DateTime? completedAt;
  final bool isCompleted;
  final int percentage;
  final int order;

  ProgressStep({
    required this.id,
    required this.kpltId,
    required this.title,
    this.description,
    this.completedAt,
    required this.isCompleted,
    required this.percentage,
    required this.order,
  });

  factory ProgressStep.fromMap(Map<String, dynamic> map) {
    return ProgressStep(
      id: map['id'],
      kpltId: map['kplt_id'],
      title: map['title'] ?? '',
      description: map['description'],
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      isCompleted: map['is_completed'] ?? false,
      percentage: map['percentage'] ?? 0,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kplt_id': kpltId,
      'title': title,
      'description': description,
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'percentage': percentage,
      'order': order,
    };
  }
}