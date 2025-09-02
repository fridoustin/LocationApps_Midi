import 'package:supabase_flutter/supabase_flutter.dart';

class UlokRemoteDataSource {
  final SupabaseClient client;
  UlokRemoteDataSource(this.client);

  // Query untuk mengambil data 'Recent'
  Future<List<Map<String, dynamic>>> getRecentUlok(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('ulok')
        .select('id, nama_ulok, alamat, kecamatan, kabupaten, provinsi, approval_status, created_at')
        .eq('users_id', userId)
        .eq('approval_status', 'In Progress');

    if (query.isNotEmpty) {
      request = request.ilike('nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    
    return response;
  }

  // Query untuk mengambil data 'History'
  Future<List<Map<String, dynamic>>> getHistoryUlok(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');
    
    var request = client
        .from('ulok')
        .select('id, nama_ulok, alamat, kecamatan, kabupaten, provinsi, approval_status, created_at')
        .eq('users_id', userId)
        .inFilter('approval_status', ['OK', 'NOK']);

    if (query.isNotEmpty) {
      request = request.ilike('nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    return response;
  }
}