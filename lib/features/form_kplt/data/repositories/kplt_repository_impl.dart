import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';

class KpltRepositoryImpl implements KpltRepository {
  final KpltRemoteDatasource dataSource;
  KpltRepositoryImpl(this.dataSource);

  // Helper untuk mengubah data Map dari Supabase menjadi objek UsulanLokasi
  FormKPLT _mapToEntity(Map<String, dynamic> map) {
    return FormKPLT(
      id: map['id'],
      ulokId: map['ulok_id'],
      namaLokasi: map['nama_ulok'],
      alamat: map['alamat'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      provinsi: map['provinsi'],
      status: map['kplt_approval'],
      tanggal: DateTime.parse(map['created_at']),
    );
  }

  @override
  Future<List<FormKPLT>> getRecentKplt(String query) async {
    final data = await dataSource.getRecentKplt(query);
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<FormKPLT>> getHistoryKplt(String query) async {
    final data = await dataSource.getHistoryKplt(query);
    return data.map(_mapToEntity).toList();
  }
}