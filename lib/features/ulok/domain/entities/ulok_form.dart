import 'package:latlong2/latlong.dart';

// Class untuk menampung semua data dari form
class UlokFormData {
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
}
