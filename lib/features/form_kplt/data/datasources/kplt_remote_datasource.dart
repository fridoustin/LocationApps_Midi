import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltRemoteDatasource {
  final SupabaseClient client;
  KpltRemoteDatasource(this.client);

  // Query untuk mengambil data 'Recent'
  Future<List<Map<String, dynamic>>> getRecentKplt({String? query}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('kplt')
        .select('*, ulok!inner(*)') 
        .eq('ulok.users_id', userId)
        .inFilter('kplt_approval', ['Waiting for Forum', 'In Progress']);

    if (query != null && query.isNotEmpty) {
      request = request.ilike('ulok.nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    
    return response;
  }

  // Query untuk mengambil data 'History'
  Future<List<Map<String, dynamic>>> getHistoryKplt({String? query}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('kplt')
        .select('*, ulok!inner(*)')
        .eq('ulok.users_id', userId)
        .inFilter('kplt_approval', ['OK', 'NOK']);

    if (query != null && query.isNotEmpty) {
      request = request.ilike('ulok.nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    return response;
  }

  Future<List<Map<String, dynamic>>> getKpltNeedInput({String? query}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    var request = client
        .from('ulok') 
        .select('*, kplt(ulok_id)')
        .eq('users_id', userId)
        .eq('approval_status', 'OK')
        .isFilter('kplt', null);

    if (query != null && query.isNotEmpty) {
      request = request.ilike('nama_ulok', '%$query%');
    }
    final response = await request.order('updated_at', ascending: false);
    return response;
  }

  // Fungsi untuk submit form KPLT
  Future<void> submitKplt(KpltFormData formData) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not Authenticated');

    try {
      final Map<String, File> filesToUpload = {
        'pdf_foto': formData.pdfFoto,
        'pdf_pembanding': formData.pdfPembanding,
        'pdf_kks': formData.pdfKks,
        'excel_fpl': formData.excelFpl,
        'excel_pe': formData.excelPe,
        'counting_kompetitor': formData.countingKompetitor,
        'pdf_form_ukur': formData.pdfFormUkur,
        'video_traffic_siang': formData.videoTrafficSiang,
        'video_traffic_malam': formData.videoTrafficMalam,
        'video_360_siang': formData.video360Siang,
        'video_360_malam': formData.video360Malam,
        'peta_coverage': formData.petaCoverage,
      };

      final List<Future> uploadTasks = [];
      final Map<String, String> filePaths = {}; 

      for (var entry in filesToUpload.entries) {
        
        final columnName = entry.key;
        final file = entry.value;

        final fileExtension = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$columnName.$fileExtension';
        final filePath = '$userId/${formData.ulokId}/$fileName';

        debugPrint("Uploading file to: $filePath");
        
        filePaths[columnName] = filePath; // Simpan path

        uploadTasks.add(client.storage.from('kplt-files').upload(
              filePath,
              file,
              fileOptions: FileOptions(
                contentType: lookupMimeType(file.path),
                upsert: false,
              ),
            ));
      }

      await Future.wait(uploadTasks);

      final Map<String, String> uploadedFileUrls = {};
      for (var entry in filePaths.entries) {
        final publicUrl = client.storage.from('kplt-files').getPublicUrl(entry.value);
        uploadedFileUrls[entry.key] = publicUrl;
      }

      final Map<String, dynamic> kpltData = {
        'ulok_id': formData.ulokId,
        'branch_id': formData.branchId,
        'karakter_lokasi': formData.karakterLokasi,
        'sosial_ekonomi': formData.sosialEkonomi,
        'pe_status': formData.peStatus,
        'skor_fpl': formData.skorFpl,
        'std': formData.std,
        'apc': formData.apc,
        'spd': formData.spd,
        'pe_rab': formData.peRab,
        ...uploadedFileUrls,
        'progress_toko': 'Running',
        'kplt_approval': 'In Progress',
        'is_active': true,
      };

      await client.from('kplt').insert(kpltData);

    } catch (e) {
      rethrow;
    }
  }
}