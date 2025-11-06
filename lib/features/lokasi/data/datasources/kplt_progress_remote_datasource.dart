import 'package:flutter/foundation.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltProgressRemoteDatasource {
  final SupabaseClient client;
  KpltProgressRemoteDatasource(this.client);

  Future<List<Map<String, dynamic>>> getRecentProgress(String query, {KpltFilter? filter}) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('User not Authenticated');

      var request = client.from('progress_kplt').select('''
            *,
            kplt!inner (
              id, nama_kplt, alamat, kecamatan, kabupaten, desa_kelurahan, provinsi, pe_status, kplt_approval,
              ulok!inner ( users_id, nama_ulok )
            )
          ''')
          .eq('kplt.ulok.users_id', userId)
          .not('status', 'eq', 'Grand Opening');

      if (query.isNotEmpty) {
        request = request.ilike('kplt.nama_kplt', '%$query%');
      }

      if (filter != null && filter.status != null) {
        request = request.eq('status', filter.status!);
      }

      if (filter != null && filter.year != null) {
        final month = filter.month ?? 1;
        final start = DateTime(filter.year!, month, 1);
        final end = DateTime(filter.year!, filter.month ?? 12, 31, 23, 59, 59);
        request = request.gte('created_at', start.toIso8601String()).lte('created_at', end.toIso8601String());
      }

      final response = await request.order('created_at', ascending: false);
      final data = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      debugPrint('✅ Found ${data.length} RECENT (Non-GO) progress for user: $userId');
      return data;

    } catch (e) {
      debugPrint('❌ getRecentProgress error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryProgress(String query, {KpltFilter? filter}) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('User not Authenticated');

      var request = client.from('progress_kplt').select('''
            *,
            kplt!inner (
              id, nama_kplt, alamat, kecamatan, kabupaten, desa_kelurahan, provinsi, pe_status, kplt_approval,
              ulok!inner ( users_id, nama_ulok )
            )
          ''')
          .eq('kplt.ulok.users_id', userId)
          .eq('status', 'Grand Opening'); 

      if (query.isNotEmpty) {
        request = request.ilike('kplt.nama_kplt', '%$query%');
      }

      if (filter != null && filter.status != null) {
        request = request.eq('status', filter.status!);
      }

      if (filter != null && filter.year != null) {
        final month = filter.month ?? 1;
        final start = DateTime(filter.year!, month, 1);
        final end = DateTime(filter.year!, filter.month ?? 12, 31, 23, 59, 59);
        request = request.gte('created_at', start.toIso8601String()).lte('created_at', end.toIso8601String());
      }

      final response = await request.order('created_at', ascending: false);
      final data = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      debugPrint('✅ Found ${data.length} HISTORY (GO) progress for user: $userId');
      return data;

    } catch (e) {
      debugPrint('❌ getHistoryProgress error: $e');
      rethrow;
    }
  }

  /// Fetch progress by kplt_id
  Future<Map<String, dynamic>?> getProgressByKpltId(String kpltId) async {
    try {
      final response = await client
          .from('progress_kplt')
          .select('''
            *,
            kplt:kplt_id (
              id,
              nama_kplt,
              alamat,
              kecamatan,
              kabupaten,
              desa_kelurahan,
              provinsi,
              status
            )
          ''')
          .eq('kplt_id', kpltId)
          .maybeSingle();

      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      debugPrint('❌ getProgressByKpltId error: $e');
      return null;
    }
  }

  /// Create progress untuk KPLT baru
  Future<String> createProgress(String kpltId) async {
    try {
      final response = await client
          .from('progress_kplt')
          .insert({
            'kplt_id': kpltId,
            'status': 'Not Started',
          })
          .select('id')
          .single();

      debugPrint('✅ Progress created: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      debugPrint('❌ createProgress error: $e');
      rethrow;
    }
  }

  /// Update status progress
  Future<void> updateStatus(String progressId, String status) async {
    try {
      await client.from('progress_kplt').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', progressId);
      
      debugPrint('✅ Status updated: $status');
    } catch (e) {
      debugPrint('❌ updateStatus error: $e');
      rethrow;
    }
  }

  /// Get progress percentage berdasarkan data dari tabel terkait
  Future<Map<String, dynamic>> getCompletionStatus(String progressId) async {
    try {
      final results = <String, dynamic>{};

      // Check MOU
      final mou = await client
          .from('mou')
          .select('tgl_selesai_mou')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['mou'] = {
        'completed': mou?['tgl_selesai_mou'] != null,
        'date': mou?['tgl_selesai_mou'],
      };

      // Check Izin Tetangga
      final izinTetangga = await client
          .from('izin_tetangga')
          .select('tgl_selesai_izintetangga')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['izin_tetangga'] = {
        'completed': izinTetangga?['tgl_selesai_izintetangga'] != null,
        'date': izinTetangga?['tgl_selesai_izintetangga'],
      };

      // Check Perizinan
      final perizinan = await client
          .from('perizinan')
          .select('tgl_selesai_perizinan')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['perizinan'] = {
        'completed': perizinan?['tgl_selesai_perizinan'] != null,
        'date': perizinan?['tgl_selesai_perizinan'],
      };

      // Check Notaris
      final notaris = await client
          .from('notaris')
          .select('tgl_selesai_notaris')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['notaris'] = {
        'completed': notaris?['tgl_selesai_notaris'] != null,
        'date': notaris?['tgl_selesai_notaris'],
      };

      // Check Renovasi
      final renovasi = await client
          .from('renovasi')
          .select('tgl_selesai_renov')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['renovasi'] = {
        'completed': renovasi?['tgl_selesai_renov'] != null,
        'date': renovasi?['tgl_selesai_renov'],
      };

      // Check Grand Opening
      final grandOpening = await client
          .from('grand_opening')
          .select('tgl_selesai_go')
          .eq('progress_kplt_id', progressId)
          .maybeSingle();
      results['grand_opening'] = {
        'completed': grandOpening?['tgl_selesai_go'] != null,
        'date': grandOpening?['tgl_selesai_go'],
      };

      return results;
    } catch (e) {
      debugPrint('❌ getCompletionStatus error: $e');
      return {};
    }
  }

  /// Get MOU data by progress_kplt_id
  Future<Map<String, dynamic>?> getMouData(String progressKpltId) async {
    try {
      final response = await client
          .from('mou')
          .select('*')
          .eq('progress_kplt_id', progressKpltId)
          .maybeSingle();

      debugPrint('✅ MOU data fetched for progress: $progressKpltId');
      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      debugPrint('❌ getMouData error: $e');
      return null;
    }
  }

  /// Get Izin Tetangga data by progress_kplt_id
  Future<Map<String, dynamic>?> getIzinTetanggaData(String progressKpltId) async {
    try {
      final response = await client
          .from('izin_tetangga')
          .select('*')
          .eq('progress_kplt_id', progressKpltId)
          .maybeSingle();

      debugPrint('✅ Izin Tetangga data fetched for progress: $progressKpltId');
      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      debugPrint('❌ getIzinTetanggaData error: $e');
      return null;
    }
  }

  /// Get Perizinan data by progress_kplt_id
  Future<Map<String, dynamic>?> getPerizinanData(String progressKpltId) async {
    try {
      final response = await client
          .from('perizinan')
          .select('*')
          .eq('progress_kplt_id', progressKpltId)
          .maybeSingle();

      debugPrint('✅ Perizinan data fetched for progress: $progressKpltId');
      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      debugPrint('❌ getPerizinanData error: $e');
      return null;
    }
  }

  /// Get History Perizinan by perizinan_id
  Future<List<Map<String, dynamic>>> getHistoryPerizinan(String perizinanId) async {
    try {
      final response = await client
          .from('history_perizinan')
          .select('*')
          .eq('perizinan_id', perizinanId)
          .order('created_at', ascending: false);

      final data = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      debugPrint('✅ Found ${data.length} history for perizinan: $perizinanId');
      return data;
    } catch (e) {
      debugPrint('❌ getHistoryPerizinan error: $e');
      return [];
    }
  }
}