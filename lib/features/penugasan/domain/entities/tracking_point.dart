enum TrackingStatus { arrived, pending, cancelled, inTransit }

class TrackingPoint {
  final String id;
  final String assignmentId;
  final String userId;
  final TrackingStatus status;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;

  TrackingPoint({
    required this.id,
    required this.assignmentId,
    required this.userId,
    required this.status,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  factory TrackingPoint.fromMap(Map<String, dynamic> map) {
    return TrackingPoint(
      id: map['id'],
      assignmentId: map['assignment_id'],
      userId: map['user_id'],
      status: _parseTrackingStatus(map['status']),
      notes: map['notes'],
      photoUrl: map['photo_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'user_id': userId,
      'status': _trackingStatusToString(status),
      'notes': notes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static TrackingStatus _parseTrackingStatus(String? value) {
    switch (value) {
      case 'arrived':
        return TrackingStatus.arrived;
      case 'pending':
        return TrackingStatus.pending;
      case 'cancelled':
        return TrackingStatus.cancelled;
      case 'in_transit':
        return TrackingStatus.inTransit;
      default:
        return TrackingStatus.inTransit;
    }
  }

  static String _trackingStatusToString(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return 'arrived';
      case TrackingStatus.pending:
        return 'pending';
      case TrackingStatus.cancelled:
        return 'cancelled';
      case TrackingStatus.inTransit:
        return 'in_transit';
    }
  }
}