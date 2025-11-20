import 'package:latlong2/latlong.dart';

class UlokEksternal {
  final String id;
  final String? usersEksternalId;
  final double latitude;
  final double longitude;
  final String desaKelurahan;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final String alamat;
  final String? bentukObjek;
  final String? alasHak;
  final int? jumlahLantai;
  final double? lebarDepan;
  final double? panjang;
  final double? luas;
  final double? hargaSewa;
  final String? namaPemilik;
  final String? kontakPemilik;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? fotoLokasi;
  final String status;

  UlokEksternal({
    required this.id,
    this.usersEksternalId,
    required this.latitude,
    required this.longitude,
    required this.desaKelurahan,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
    required this.alamat,
    this.bentukObjek,
    this.alasHak,
    this.jumlahLantai,
    this.lebarDepan,
    this.panjang,
    this.luas,
    this.hargaSewa,
    this.namaPemilik,
    this.kontakPemilik,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.fotoLokasi,
    required this.status,
  });

  factory UlokEksternal.fromMap(Map<String, dynamic> map) {
    return UlokEksternal(
      id: map['id'],
      usersEksternalId: map['users_eksternal_id'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      desaKelurahan: map['desa_kelurahan'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      kabupaten: map['kabupaten'] ?? '',
      provinsi: map['provinsi'] ?? '',
      alamat: map['alamat'] ?? '',
      bentukObjek: map['bentuk_objek'],
      alasHak: map['alas_hak'],
      jumlahLantai: map['jumlah_lantai'],
      lebarDepan: (map['lebar_depan'] as num?)?.toDouble(),
      panjang: (map['panjang'] as num?)?.toDouble(),
      luas: (map['luas'] as num?)?.toDouble(),
      hargaSewa: (map['harga_sewa'] as num?)?.toDouble(),
      namaPemilik: map['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      approvedAt: map['approved_at'] != null 
          ? DateTime.parse(map['approved_at']) 
          : null,
      fotoLokasi: map['foto_lokasi'],
      status: map['status_ulok_eksternal'] ?? 'Pending',
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
  
  String get fullAddress => [
    alamat,
    desaKelurahan,
    kecamatan.isNotEmpty ? 'Kec. $kecamatan' : '',
    kabupaten,
    provinsi,
  ].where((e) => e.isNotEmpty).join(', ');
}