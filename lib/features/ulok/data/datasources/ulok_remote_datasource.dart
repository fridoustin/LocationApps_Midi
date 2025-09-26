import 'package:supabase_flutter/supabase_flutter.dart';

class UlokRemoteDataSource {
  final SupabaseClient client;
  UlokRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> getRecentUlok(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('ulok')
        .select('''
          id, nama_ulok, alamat, kecamatan, desa_kelurahan, kabupaten, provinsi,
          latitude, longitude,
          approval_status, created_at,
          format_store, bentuk_objek, alas_hak, jumlah_lantai,
          lebar_depan, panjang, luas, harga_sewa,
          nama_pemilik, kontak_pemilik, form_ulok
        ''')
        .eq('users_id', userId)
        .eq('approval_status', 'In Progress');

    if (query.isNotEmpty) {
      request = request.ilike('nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);

    return response;
  }

  Future<List<Map<String, dynamic>>> getHistoryUlok(String query) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');
    
    var request = client
        .from('ulok')
        .select('''
          id, nama_ulok, alamat, kecamatan, desa_kelurahan, kabupaten, provinsi,
          latitude, longitude,
          approval_status, created_at,
          format_store, bentuk_objek, alas_hak, jumlah_lantai,
          lebar_depan, panjang, luas, harga_sewa,
          nama_pemilik, kontak_pemilik, form_ulok
        ''')
        .eq('users_id', userId)
        .inFilter('approval_status', ['OK', 'NOK']);

    if (query.isNotEmpty) {
      request = request.ilike('nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    return response;
  }

  Future<Map<String, dynamic>> getUlokById(String ulokId) async {
    try {
      final response = await client
          .from('ulok')
          .select('*') 
          .eq('id', ulokId)
          .single(); 
      return response;
    } catch (e) {
      print('Error fetching ULOK by ID: $e');
      rethrow;
    }
  }
}
