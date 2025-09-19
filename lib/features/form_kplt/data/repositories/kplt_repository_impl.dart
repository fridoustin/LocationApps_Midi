import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';

class KpltRepositoryImpl implements KpltRepository {
  final KpltRemoteDatasource dataSource;
  KpltRepositoryImpl(this.dataSource);

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  // Mapper #1: Untuk data yang berasal dari tabel KPLT
  FormKPLT _mapKpltToEntity(Map<String, dynamic> map) {
    final ulokData = map['ulok']; 
    final lat = ulokData['latitude'];
    final lon = ulokData['longitude'];
    String? combinedLatLong;
    if (lat != null && lon != null) {
      combinedLatLong = '$lat,$lon';
    }
    if (ulokData == null) {
      return FormKPLT(id: map['id'] ?? '', ulokId: map['ulok_id'] ?? '', namaLokasi: 'Data Ulok Hilang', alamat: '', kecamatan: '', kabupaten: '', provinsi: '', desa_kelurahan: '', status: map['kplt_approval'] ?? 'Error', tanggal: DateTime.now());
    }
    return FormKPLT(
      id: map['id'], 
      ulokId: map['ulok_id'],
      namaLokasi: ulokData['nama_ulok'],
      alamat: ulokData['alamat'],
      kecamatan: ulokData['kecamatan'],
      kabupaten: ulokData['kabupaten'],
      provinsi: ulokData['provinsi'],
      desa_kelurahan: ulokData['desa_kelurahan'],
      status: map['kplt_approval'], 
      tanggal: DateTime.parse(map['created_at']),
      latLong: combinedLatLong,
      formatStore: ulokData['format_store'],
      bentukObjek: ulokData['bentuk_objek'],
      alasHak: ulokData['alas_hak'],
      jumlahLantai: ulokData['jumlah_lantai'] as int?,
      lebarDepan: _toDouble(ulokData['lebar_depan']),
      panjang: _toDouble(ulokData['panjang']),
      luas: _toDouble(ulokData['luas']),
      hargaSewa: _toDouble(ulokData['harga_sewa']),
      namaPemilik: ulokData['nama_pemilik'],
      kontakPemilik: ulokData['kontak_pemilik'],
    );
  }

  // Mapper #2: Untuk data yang berasal dari tabel ULOK
  FormKPLT _mapUlokToEntity(Map<String, dynamic> map) {
    final lat = map['latitude'];
    final lon = map['longitude'];
    String? combinedLatLong;
    if (lat != null && lon != null) {
      combinedLatLong = '$lat,$lon';
    }
    return FormKPLT(
      id: map['id'], 
      ulokId: map['id'], 
      namaLokasi: map['nama_ulok'],
      alamat: map['alamat'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      provinsi: map['provinsi'],
      desa_kelurahan: map['desa_kelurahan'],
      status: 'Need Input', 
      tanggal: DateTime.parse(map['updated_at']), 
      latLong: combinedLatLong,
      formatStore: map['format_store'],
      bentukObjek: map['bentuk_objek'],
      alasHak: map['alas_hak'],
      jumlahLantai: map['jumlah_lantai'] as int?,
      lebarDepan: _toDouble(map['lebar_depan']),
      panjang: _toDouble(map['panjang']),
      luas: _toDouble(map['luas']),
      hargaSewa: _toDouble(map['harga_sewa']),
      namaPemilik: map['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'],
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

  @override
  Future<void> submitKplt(KpltFormData formData) async {
    try {
      await dataSource.submitKplt(formData);
    } catch (e) {
      rethrow;
    }
  }
}