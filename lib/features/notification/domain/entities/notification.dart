class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? ulokId;
  final String? ulokStatus;
  final String? kpltId;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.ulokId,
    this.ulokStatus,
    this.kpltId,
  });

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      isRead: map['is_read'],
      createdAt: DateTime.parse(map['created_at']),
      ulokId: map['ulok_id'],
    );
  }
}