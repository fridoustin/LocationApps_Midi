import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/notification/data/datasources/notification_datasource.dart';
import 'package:midi_location/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:midi_location/features/notification/domain/entities/notification.dart';
import 'package:midi_location/features/notification/domain/repositories/notification_repository.dart';

// Providers untuk Data Layer
final notificationDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.watch(supabaseClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationDataSourceProvider));
});

// Provider utama untuk daftar notifikasi
final notificationListProvider = FutureProvider<List<NotificationEntity>>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});
