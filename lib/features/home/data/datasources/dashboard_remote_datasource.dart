import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient _client;
  DashboardRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getDashboardStats({required String timeRange}) async {
    // Panggil fungsi database yang sudah kita buat
    final data = await _client.rpc(
      'get_dashboard_stats',
      params: {'time_range': timeRange},
    );
    return data as Map<String, dynamic>;
  }
}
