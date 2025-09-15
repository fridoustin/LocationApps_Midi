import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class UlokFormData {
  final String localId;
  final String namaUlok;
  final LatLng latLng;
  final String provinsi;
  final String kabupaten;
  final String kecamatan;
  final String desa;
  final String alamat;
  final String formatStore;
  final String bentukObjek;
  final String alasHak;
  final int jumlahLantai;
  final double lebarDepan;
  final double panjang;
  final double luas;
  final double hargaSewa;
  final String namaPemilik;
  final String kontakPemilik;

  UlokFormData({
    required this.localId,
    required this.namaUlok,
    required this.latLng,
    required this.provinsi,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
    required this.alamat,
    required this.formatStore,
    required this.bentukObjek,
    required this.alasHak,
    required this.jumlahLantai,
    required this.lebarDepan,
    required this.panjang,
    required this.luas,
    required this.hargaSewa,
    required this.namaPemilik,
    required this.kontakPemilik,
  });

  /// Mengubah objek menjadi Map untuk disimpan di local storage (SharedPreferences)
  Map<String, dynamic> toLocalJson() {
    return {
      'localId': localId,
      'namaUlok': namaUlok,
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'desa': desa,
      'alamat': alamat,
      'formatStore': formatStore,
      'bentukObjek': bentukObjek,
      'alasHak': alasHak,
      'jumlahLantai': jumlahLantai,
      'lebarDepan': lebarDepan,
      'panjang': panjang,
      'luas': luas,
      'hargaSewa': hargaSewa,
      'namaPemilik': namaPemilik,
      'kontakPemilik': kontakPemilik,
    };
  }

  /// Mengubah objek menjadi Map untuk dikirim sebagai payload ke Supabase
  Map<String, dynamic> toSupabaseJson(String branchId) {
    return {
      'nama_ulok': namaUlok,
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'desa': desa,
      'alamat': alamat,
      'format_store': formatStore,
      'bentuk_objek': bentukObjek,
      'alas_hak': alasHak,
      'jumlah_lantai': jumlahLantai,
      'lebar_depan': lebarDepan,
      'panjang': panjang,
      'luas': luas,
      'harga_sewa': hargaSewa,
      'nama_pemilik': namaPemilik,
      'kontak_pemilik': kontakPemilik,
      'branch_id': branchId,
    };
  }

  /// Membuat objek dari data JSON yang disimpan secara lokal
  factory UlokFormData.fromJson(Map<String, dynamic> json) {
    return UlokFormData(
      localId: json['localId'] ?? const Uuid().v4(),
      namaUlok: json['namaUlok'] ?? '',
      latLng: LatLng(json['latitude'] ?? 0.0, json['longitude'] ?? 0.0),
      provinsi: json['provinsi'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      desa: json['desa'] ?? '',
      alamat: json['alamat'] ?? '',
      formatStore: json['formatStore'] ?? '',
      bentukObjek: json['bentukObjek'] ?? '',
      alasHak: json['alasHak'] ?? '',
      jumlahLantai: json['jumlahLantai'] ?? 0,
      lebarDepan: json['lebarDepan'] ?? 0.0,
      panjang: json['panjang'] ?? 0.0,
      luas: json['luas'] ?? 0.0,
      hargaSewa: json['hargaSewa'] ?? 0.0,
      namaPemilik: json['namaPemilik'] ?? '',
      kontakPemilik: json['kontakPemilik'] ?? '',
    );
  }
}