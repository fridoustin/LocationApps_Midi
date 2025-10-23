// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/cupertino.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UlokFormRemoteDataSource {
  final SupabaseClient _client;
  UlokFormRemoteDataSource(this._client);

  Future<void> submitUlok(UlokFormData data, String branchId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final ulokId = data.localId;
    String? formUlokPath;

    if (data.formUlokPdf != null) {
      final file = data.formUlokPdf!;
      final fileExtension = file.path.split('.').last;
      final filePath = '$ulokId/ulok/${DateTime.now().millisecondsSinceEpoch}_form_ulok.$fileExtension';

      await _client.storage.from('file_storage').upload(
            filePath,
            file,
            fileOptions: FileOptions(
              contentType: lookupMimeType(file.path),
            ),
          );

      formUlokPath = filePath;
    }
  
    final Map<String, dynamic> row = {
      'id': ulokId,
      'users_id': userId,
      'branch_id': branchId,
      'nama_ulok': data.namaUlok,
      'latitude': data.latLng.latitude.toString(),
      'longitude': data.latLng.longitude.toString(),
      'provinsi': data.provinsi,
      'kabupaten': data.kabupaten,
      'kecamatan': data.kecamatan,
      'desa_kelurahan': data.desa,
      'alamat': data.alamat,
      'format_store': data.formatStore,
      'bentuk_objek': data.bentukObjek,
      'alas_hak': data.alasHak,
      'jumlah_lantai': data.jumlahLantai,
      'lebar_depan': data.lebarDepan,
      'panjang': data.panjang,
      'luas': data.luas,
      'harga_sewa': data.hargaSewa,
      'nama_pemilik': data.namaPemilik,
      'kontak_pemilik': data.kontakPemilik,
      'approval_status': 'In Progress',
      'is_active': true,
      'form_ulok': formUlokPath,
    };

    await _client.from('ulok').insert(row);
  }

  Future<void> updateUlok(String ulokId, UlokFormData data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try{
      final Map<String, dynamic> rowData = {
        'nama_ulok': data.namaUlok,
        'latitude': data.latLng.latitude,
        'longitude': data.latLng.longitude,
        'provinsi': data.provinsi,
        'kabupaten': data.kabupaten,
        'kecamatan': data.kecamatan,
        'desa_kelurahan': data.desa,
        'alamat': data.alamat,
        'format_store': data.formatStore,
        'bentuk_objek': data.bentukObjek,
        'alas_hak': data.alasHak,
        'jumlah_lantai': data.jumlahLantai,
        'lebar_depan': data.lebarDepan,
        'panjang': data.panjang,
        'luas': data.luas,
        'harga_sewa': data.hargaSewa,
        'nama_pemilik': data.namaPemilik,
        'kontak_pemilik': data.kontakPemilik,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (data.formUlokPdf != null) {
        if (data.existingFormUlokUrl != null && data.existingFormUlokUrl!.isNotEmpty) {
          try {
            await _client.storage.from('file_storage').remove([data.existingFormUlokUrl!]);
          } catch (e) {
            debugPrint("Gagal menghapus file lama: $e");
          }
        }

        final file = data.formUlokPdf!;
        final fileExtension = file.path.split('.').last;
        final filePath = '$ulokId/ulok/${DateTime.now().millisecondsSinceEpoch}_form_ulok.$fileExtension';

        await _client.storage.from('file_storage').upload(
              filePath,
              file,
              fileOptions: FileOptions(upsert: false),
            );
        
        rowData['form_ulok'] = filePath;
      }
      
      await _client.from('ulok').update(rowData).eq('id', ulokId);

    } catch (e) {
      rethrow;
    }
  }
}