import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient _client;
  DashboardRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getDashboardStats({required String timeRange}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not authenticated');
    }
    // Panggil fungsi database yang sudah kita buat
    final data = await _client.rpc(
      'get_dashboard_stats',
      params: {
        'time_range': timeRange,
        'p_user_id': userId,
      },
    );
    return data as Map<String, dynamic>;
  }
}
