class FormKPLT {
  final String id;
  final String ulokId;
  final String namaLokasi;
  final String alamat;
  final String kecamatan;
  final String desaKelurahan;
  final String kabupaten;
  final String provinsi;
  final String status;
  final DateTime tanggal;
  final String? latLong;
  final String? formatStore;
  final String? bentukObjek;
  final String? alasHak;
  final int? jumlahLantai;
  final double? lebarDepan;
  final double? panjang;
  final double? luas;
  final double? hargaSewa;
  final String? namaPemilik;
  final String? kontakPemilik;

  FormKPLT({
    required this.id,
    required this.ulokId,
    required this.namaLokasi,
    required this.alamat,
    required this.kecamatan,
    required this.desaKelurahan,
    required this.kabupaten,
    required this.provinsi,
    required this.status,
    required this.tanggal,
    this.latLong,
    this.formatStore,
    this.bentukObjek,
    this.alasHak,
    this.jumlahLantai,
    this.lebarDepan,
    this.panjang,
    this.luas,
    this.hargaSewa,
    this.namaPemilik,
    this.kontakPemilik,
  });
}