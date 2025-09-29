import 'package:midi_location/features/ulok/domain/entities/ulok_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UlokRemoteDataSource {
  final SupabaseClient client;
  UlokRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> getRecentUlok({required String query, required UlokFilter filter}) async {
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

    if (filter.status != null) {
      request = request.eq('approval_status', filter.status!);
    }
    
    if (filter.year != null && (filter.month == null)) {
      final startYear = DateTime(filter.year!, 1, 1);
      final startYearStr = startYear.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final nextYear = DateTime(filter.year! + 1, 1, 1);
      final nextYearStr = nextYear.toIso8601String().split('T')[0];
      request = request.filter('created_at', 'gte', startYearStr);
      request = request.filter('created_at', 'lt', nextYearStr);
    }
    if (filter.month != null && filter.year != null) {
      final startOfMonth = DateTime(filter.year!, filter.month!, 1);
      DateTime startOfNextMonth;
      if (filter.month == 12) {
        startOfNextMonth = DateTime(filter.year! + 1, 1, 1);
      } else {
        startOfNextMonth = DateTime(filter.year!, filter.month! + 1, 1);
      }
      final startStr = startOfMonth.toIso8601String().split('T')[0];
      final nextStr = startOfNextMonth.toIso8601String().split('T')[0];

      request = request.filter('created_at', 'gte', startStr);
      request = request.filter('created_at', 'lt', nextStr);
    }

    final response = await request.order('created_at', ascending: false);

    return response;
  }

  Future<List<Map<String, dynamic>>> getHistoryUlok({required String query, required UlokFilter filter}) async {
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

    if (filter.status != null) {
      request = request.eq('approval_status', filter.status!);
    }

    if (filter.year != null && (filter.month == null)) {
      final startYear = DateTime(filter.year!, 1, 1);
      final startYearStr = startYear.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final nextYear = DateTime(filter.year! + 1, 1, 1);
      final nextYearStr = nextYear.toIso8601String().split('T')[0];
      request = request.filter('created_at', 'gte', startYearStr);
      request = request.filter('created_at', 'lt', nextYearStr);
    }
    if (filter.month != null && filter.year != null) {
      final startOfMonth = DateTime(filter.year!, filter.month!, 1);
      DateTime startOfNextMonth;
      if (filter.month == 12) {
        startOfNextMonth = DateTime(filter.year! + 1, 1, 1);
      } else {
        startOfNextMonth = DateTime(filter.year!, filter.month! + 1, 1);
      }
      final startStr = startOfMonth.toIso8601String().split('T')[0];
      final nextStr = startOfNextMonth.toIso8601String().split('T')[0];

      request = request.filter('created_at', 'gte', startStr);
      request = request.filter('created_at', 'lt', nextStr);
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
