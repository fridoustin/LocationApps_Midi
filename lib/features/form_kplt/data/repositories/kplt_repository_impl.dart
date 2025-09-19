import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';

class KpltRepositoryImpl implements KpltRepository {
  final KpltRemoteDatasource dataSource;
  KpltRepositoryImpl(this.dataSource);

  // Mapper #1: Untuk data yang berasal dari tabel KPLT
  FormKPLT _mapKpltToEntity(Map<String, dynamic> map) {
    final ulokData = map['ulok']; // Data ulok ada di dalam nested object
    return FormKPLT(
      id: map['id'], 
      ulokId: map['ulok_id'],
      namaLokasi: ulokData['nama_ulok'],
      alamat: ulokData['alamat'],
      kecamatan: ulokData['kecamatan'],
      kabupaten: ulokData['kabupaten'],
      provinsi: ulokData['provinsi'],
      status: map['kplt_approval'], 
      tanggal: DateTime.parse(map['created_at']),
    );
  }

  // Mapper #2: Untuk data yang berasal dari tabel ULOK
  FormKPLT _mapUlokToEntity(Map<String, dynamic> map) {
    return FormKPLT(
      id: map['id'], 
      ulokId: map['id'], 
      namaLokasi: map['nama_ulok'],
      alamat: map['alamat'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      provinsi: map['provinsi'],
      status: 'Need Input', 
      tanggal: DateTime.parse(map['updated_at']), 
    );
  }

  @override
  Future<List<FormKPLT>> getRecentKplt(String query) async {
    final data = await dataSource.getRecentKplt(query: query);
    return data.map(_mapKpltToEntity).toList();
  }

  @override
  Future<List<FormKPLT>> getKpltNeedInput(String query) async {
    final data = await dataSource.getKpltNeedInput(query: query);
    return data.map(_mapUlokToEntity).toList();
  }

  @override
  Future<List<FormKPLT>> getHistoryKplt(String query) async {
    final data = await dataSource.getHistoryKplt(query: query);
    return data.map(_mapKpltToEntity).toList();
  }
}