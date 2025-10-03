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
    final List<String> uploadedFilePaths = [];

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

      final Map<String, String> uploadedFileColumnData = {};

      for (final entry in filesToUpload.entries) {
        final columnName = entry.key;
        final file = entry.value;
        final ulokId = formData.ulokId;
        final fileExtension = file.path.split('.').last;
        final filePath = '$ulokId/kplt/${DateTime.now().millisecondsSinceEpoch}_$columnName.$fileExtension';

        debugPrint("Uploading file to: $filePath");
        
        await client.storage.from('file_storage').upload(
          filePath,
          file,
          fileOptions: FileOptions(
            contentType: lookupMimeType(file.path),
            upsert: false,
          ),
        );

        uploadedFilePaths.add(filePath);
        uploadedFileColumnData[columnName] = filePath;
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
        ...uploadedFileColumnData,
        'progress_toko': 'Running',
        'kplt_approval': 'In Progress',
        'is_active': true,
        'nama_kplt': formData.namaKplt,
        'latitude': formData.latLng.latitude,
        'longitude': formData.latLng.longitude,
        'desa_kelurahan': formData.desa,
        'kecamatan': formData.kecamatan,
        'kabupaten': formData.kabupaten,
        'provinsi': formData.provinsi,
        'alamat': formData.alamat,
        'format_store': formData.formatStore,
        'bentuk_objek': formData.bentukObjek,
        'alas_hak': formData.alasHak,
        'jumlah_lantai': formData.jumlahLantai,
        'lebar_depan': formData.lebarDepan,
        'panjang': formData.panjang,
        'luas': formData.luas,
        'harga_sewa': formData.hargaSewa,
        'nama_pemilik': formData.namaPemilik,
        'kontak_pemilik': formData.kontakPemilik,
        'form_ulok': formData.formUlok,
        'approval_intip_status': formData.approvalIntip,
        'tanggal_approval_intip': formData.tanggalApprovalIntip.toIso8601String(),
        'file_intip': formData.fileIntip
      };
      await client.from('kplt').insert(kpltData);

    } catch (e) {
      debugPrint("Error submitting KPLT: $e. Rolling back storage uploads...");
      if (uploadedFilePaths.isNotEmpty) {
        await client.storage.from('file_storage').remove(uploadedFilePaths);
        debugPrint("Rollback successful. Deleted files: $uploadedFilePaths");
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getKpltById(String kpltId) async {
    try {
      final response = await client
          .from('kplt')
          .select() 
          .eq('id', kpltId) 
          .single(); 

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateKplt(String kpltId, Map<String, dynamic> data) async {
    try {
      await client
          .from('kplt')
          .update(data)
          .eq('id', kpltId);
    } catch (e) {
      rethrow;
    }
  }
}