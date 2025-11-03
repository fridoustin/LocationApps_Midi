import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltProgressRemoteDatasource {
  final SupabaseClient client;
  KpltProgressRemoteDatasource(this.client);

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await client
        .from('progress_kplt')
        .select('''
          *,
          kplt!inner (
            id,
            nama_kplt,
            alamat,
            kecamatan,
            kabupaten,
            provinsi,
            pe_status,
            kplt_approval,
            ulok!inner (
              users_id
            )
          )
        ''')
        .eq('kplt.ulok.users_id', userId)
        .order('created_at', ascending: false);
      
      final data = (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

      debugPrint('✅ Found ${data.length} progress for user: $userId');
      return data;
      
    } catch (e) {
      debugPrint('❌ getAllProgress error: $e');
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
            'status': 'not_started',
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
}