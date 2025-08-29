import 'package:midi_location/features/ulok/data/datasources/ulok_remote_datasource.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_repository.dart';

class UlokRepositoryImpl implements UlokRepository {
  final UlokRemoteDataSource dataSource;
  UlokRepositoryImpl(this.dataSource);

  // Helper untuk mengubah data Map dari Supabase menjadi objek UsulanLokasi
  UsulanLokasi _mapToEntity(Map<String, dynamic> map) {
    return UsulanLokasi(
      id: map['id'],
      namaLokasi: map['nama_ulok'],
      alamat: map['alamat'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      provinsi: map['provinsi'],
      status: map['approval_status'],
      tanggal: DateTime.parse(map['created_at']),
    );
  }

  @override
  Future<List<UsulanLokasi>> getRecentUlok(String query) async {
    final data = await dataSource.getRecentUlok(query);
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<UsulanLokasi>> getHistoryUlok(String query) async {
    final data = await dataSource.getHistoryUlok(query);
    return data.map(_mapToEntity).toList();
  }
}