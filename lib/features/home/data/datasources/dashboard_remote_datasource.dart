// lib/features/home/data/datasources/dashboard_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient _client;
  DashboardRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getDashboardStats({
    required int year,
    int? month,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not authenticated');
    }

    final data = await _client.rpc(
      'get_app_dashboard',
      params: {'p_year': year, 'p_user_id': userId},
    );

    if (data is List) {
      return (data.isNotEmpty ? data.first : {}) as Map<String, dynamic>;
    }

    return data as Map<String, dynamic>;
  }
}
