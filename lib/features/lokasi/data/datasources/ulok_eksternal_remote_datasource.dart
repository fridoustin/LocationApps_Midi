import 'package:supabase_flutter/supabase_flutter.dart';

class UlokEksternalRemoteDataSource {
  final SupabaseClient _supabase;

  UlokEksternalRemoteDataSource(this._supabase);

  Future<Map<String, dynamic>> getUlokEksternalById(String id) async {
    try {
      final response = await _supabase
          .from('ulok_eksternal')
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Gagal mengambil data Ulok Eksternal: $e');
    }
  }
}