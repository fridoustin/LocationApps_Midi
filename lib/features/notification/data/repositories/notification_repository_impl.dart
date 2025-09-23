import 'package:midi_location/features/notification/data/datasources/notification_datasource.dart';
import 'package:midi_location/features/notification/domain/entities/notification.dart';
import 'package:midi_location/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  NotificationRepositoryImpl(this._dataSource);

  NotificationEntity _mapToEntity(Map<String, dynamic> map) {
  final ulokData = map['ulok'] as Map<String, dynamic>?;
  final kpltDataList = ulokData?['kplt'] as List?;
  final String? kpltId = (kpltDataList != null && kpltDataList.isNotEmpty)
      ? kpltDataList.first['id']
      : null;

  return NotificationEntity(
    id: map['id'],
    title: map['title'],
    body: map['body'],
    isRead: map['is_read'],
    createdAt: DateTime.parse(map['created_at']),
    ulokId: map['ulok_id'],
    ulokStatus: ulokData?['approval_status'],
    kpltId: kpltId,
  );
}

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final data = await _dataSource.getNotifications();
    return data.map(_mapToEntity).toList();
  }
  
  @override
  Future<void> markAsRead(String notificationId) {
    return _dataSource.markAsRead(notificationId);
  }
}