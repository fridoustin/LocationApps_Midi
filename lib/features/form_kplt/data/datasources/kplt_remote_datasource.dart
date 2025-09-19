import 'package:supabase_flutter/supabase_flutter.dart';

class KpltRemoteDatasource {
  final SupabaseClient client;
  KpltRemoteDatasource(this.client);

  // Query untuk mengambil data 'Recent'
  Future<List<Map<String, dynamic>>> getRecentKplt(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('kplt')
        .select('id, ulok_id, created_at, kplt_approval, ulok!inner(id, nama_ulok, alamat, kecamatan, kabupaten, provinsi)')
        .eq('ulok.users_id', userId)
        .inFilter('kplt_approval', ['Waiting for Forum', 'In Progress']);

    if (query.isNotEmpty) {
      request = request.ilike('ulok.nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    
    return response;
  }

  // Query untuk mengambil data 'History'
  Future<List<Map<String, dynamic>>> getHistoryKplt(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('kplt')
        .select('id, ulok_id, created_at, kplt_approval, ulok!inner(id, nama_ulok, alamat, kecamatan, kabupaten, provinsi)')
        .eq('ulok.users_id', userId)
        .inFilter('kplt_approval', ['OK', 'NOK']);

    if (query.isNotEmpty) {
      request = request.ilike('ulok.nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    return response;
  }
}