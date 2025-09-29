import 'package:midi_location/features/ulok/data/datasources/ulok_remote_datasource.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_filter.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_repository.dart';

class UlokRepositoryImpl implements UlokRepository {
  final UlokRemoteDataSource dataSource;
  UlokRepositoryImpl(this.dataSource);

  UsulanLokasi _mapToEntity(Map<String, dynamic> map) {
    return UsulanLokasi(
      id: map['id'],
      namaLokasi: map['nama_ulok'],
      alamat: map['alamat'],
      desaKelurahan: map['desa_kelurahan'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      provinsi: map['provinsi'],
      status: map['approval_status'],
      tanggal: DateTime.parse(map['created_at']),
      latLong:
          (map['latitude'] != null && map['longitude'] != null)
              ? "${map['latitude']},${map['longitude']}"
              : null,
      formatStore: map['format_store'],
      bentukObjek: map['bentuk_objek'],
      alasHak: map['alas_hak'],
      jumlahLantai: map['jumlah_lantai'],
      lebarDepan: (map['lebar_depan'] as num?)?.toDouble(),
      panjang: (map['panjang'] as num?)?.toDouble(),
      luas: (map['luas'] as num?)?.toDouble(),
      hargaSewa: (map['harga_sewa'] as num?)?.toDouble(),
      namaPemilik: map['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'],
      formUlok: map['form_ulok']
    );
  }

  @override
  Future<List<UsulanLokasi>> getRecentUlok({required String query, required UlokFilter filter}) async {
    final data = await dataSource.getRecentUlok(query: query, filter: filter);
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<UsulanLokasi>> getHistoryUlok({required String query, required UlokFilter filter}) async {
    final data = await dataSource.getHistoryUlok(query: query, filter: filter);
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<UsulanLokasi> getUlokById(String ulokId) async {
    final data = await dataSource.getUlokById(ulokId);
    return _mapToEntity(data);
  }
}
