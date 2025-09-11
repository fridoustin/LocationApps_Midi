import 'package:midi_location/features/notification/data/datasources/notification_datasource.dart';
import 'package:midi_location/features/notification/domain/entities/notification.dart';
import 'package:midi_location/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final data = await _dataSource.getNotifications();
    return data.map((map) => NotificationEntity.fromMap(map)).toList();
  }
  
  @override
  Future<void> markAsRead(String notificationId) {
    return _dataSource.markAsRead(notificationId);
  }
}