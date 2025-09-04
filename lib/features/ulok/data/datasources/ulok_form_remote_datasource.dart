import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UlokFormRemoteDataSource {
  final SupabaseClient _client;
  UlokFormRemoteDataSource(this._client);

  Future<void> submitUlok(UlokFormData data, String branchId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final Map<String, dynamic> row = {
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
    };

    await _client.from('ulok').insert(row);
  }
}
