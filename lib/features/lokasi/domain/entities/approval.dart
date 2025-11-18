class Approval {
  final String id;
  final String kpltId;
  final bool isApproved;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final String approverRole;
  final String approverName;

  Approval({
    required this.id,
    required this.kpltId,
    required this.isApproved,
    this.approvedAt,
    required this.createdAt,
    required this.approverRole,
    required this.approverName,
  });

  factory Approval.fromMap(Map<String, dynamic> map) {
    String approverName = 'Unknown';
    String approverRole = 'Unknown';
    
    final approvedByData = map['approved_by'];
    if (approvedByData is Map<String, dynamic>) {
      approverName = approvedByData['nama'] ?? 'Unknown';
      final positionData = approvedByData['position_id'];
      if (positionData is Map<String, dynamic>) {
        approverRole = positionData['nama'] ?? 'Unknown';
      }
    }

    return Approval(
      id: map['id'] ?? '',
      kpltId: map['kplt_id'] ?? '',
      isApproved: map['is_approved'] ?? false,
      approvedAt: map['approved_at'] != null 
          ? DateTime.parse(map['approved_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      approverRole: approverRole,
      approverName: approverName,
    );
  }
}