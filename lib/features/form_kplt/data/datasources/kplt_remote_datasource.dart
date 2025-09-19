import 'dart:io';

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
        .select('id, ulok_id, created_at, kplt_approval, ulok!inner(id, nama_ulok, alamat, kecamatan, kabupaten, provinsi)')
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
        .select('id, ulok_id, created_at, kplt_approval, ulok!inner(id, nama_ulok, alamat, kecamatan, kabupaten, provinsi)')
        .eq('ulok.users_id', userId)
        .inFilter('kplt_approval', ['OK', 'NOK']);

    if (query != null && query.isNotEmpty) {
      request = request.ilike('ulok.nama_ulok', '%$query%');
    }

    final response = await request.order('created_at', ascending: false);
    return response;
  }

  // Fungsi untuk mengambil data ULOK yang butuh input KPLT
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
      // Untuk menyimpan URL file yang sudah di-upload
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

      final Map<String, String> uploadedFileUrls = {};

      // Looping untuk upload setiap file
      for (var entry in filesToUpload.entries) {
        final columnName = entry.key;
        final file = entry.value;
        
        // Membuat nama file yang unik untuk menghindari tumpang tindih
        final fileExtension = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        final filePath = '$userId/${formData.ulokId}/$fileName';

        // Meng-upload file ke Supabase Storage
        await client.storage.from('kplt-files').upload(
              filePath,
              file,
              fileOptions: FileOptions(
                contentType: lookupMimeType(file.path), // Mendeteksi tipe konten secara otomatis
                upsert: false,
              ),
            );

        // Mendapatkan URL publik dari file yang baru di-upload
        final publicUrl = client.storage.from('kplt-files').getPublicUrl(filePath);
        uploadedFileUrls[columnName] = publicUrl;
      }

      // Untuk menyimpan data form KPLT ke dalam tabel 'kplt'
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
        'kplt_': 'In Progress', 
      };

      // --- Langkah 3: Masukkan data ke tabel 'kplt' ---
      await client.from('kplt').insert(kpltData);

    } catch (e) {
      rethrow;
    }
  }
}