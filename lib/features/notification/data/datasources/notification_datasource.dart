import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _client;
  NotificationRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    return _client
        .from('notifications')
        .select('*, ulok:ulok_id(*, kplt(*))') 
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> markAsRead(String notificationId) {
    return _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}