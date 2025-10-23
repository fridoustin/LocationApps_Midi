import 'package:midi_location/features/lokasi/domain/entities/progress_step.dart';

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
  final String? formUlok;
  final String? approvalIntip;
  final DateTime? tanggalApprovalIntip;
  final String? fileIntip;
  final String? karakterLokasi;
  final String? sosialEkonomi;
  final String? peStatus;
  final double? skorFpl;
  final double? std;
  final double? apc;
  final double? spd;
  final double? peRab;
  final String? pdfFoto;
  final String? countingKompetitor;
  final String? pdfPembanding;
  final String? pdfKks;
  final String? excelFpl;
  final String? excelPe;
  final String? pdfFormUkur;
  final String? videoTrafficSiang;
  final String? videoTrafficMalam;
  final String? video360Siang;
  final String? video360Malam;
  final String? petaCoverage;
  final double? progressPercentage;
  final List<ProgressStep>? progressSteps;

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
    this.formUlok,
    this.approvalIntip,
    this.fileIntip,
    this.tanggalApprovalIntip,
    this.karakterLokasi,
    this.sosialEkonomi,
    this.peStatus,
    this.skorFpl,
    this.std,
    this.apc,
    this.spd,
    this.peRab,
    this.pdfFoto,
    this.countingKompetitor,
    this.pdfPembanding,
    this.pdfKks,
    this.excelFpl,
    this.excelPe,
    this.pdfFormUkur,
    this.videoTrafficSiang,
    this.videoTrafficMalam,
    this.video360Siang,
    this.video360Malam,
    this.petaCoverage,
    this.progressPercentage,
    this.progressSteps,
  });

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Factory #1: Untuk data dari KPLT yang di-join dengan ULOK (Recent & History)
  factory FormKPLT.fromJoinedKpltMap(Map<String, dynamic> map) {
    final ulokData = map['ulok'] as Map<String, dynamic>?;

    if (ulokData == null) {
      return FormKPLT(id: map['id'] ?? '', ulokId: map['ulok_id'] ?? '', namaLokasi: 'Data Ulok Hilang', alamat: '', kecamatan: '', kabupaten: '', provinsi: '', desaKelurahan: '', status: map['kplt_approval'] ?? 'Error', tanggal: DateTime.parse(map['created_at']));
    }

    final lat = _parseDouble(ulokData['latitude']);
    final lon = _parseDouble(ulokData['longitude']);
    String? latLongValue;
    if (lat != null && lon != null) {
      latLongValue = '$lat,$lon';
    }
    
    return FormKPLT(
      id: map['id'],
      ulokId: map['ulok_id'],
      status: map['kplt_approval'],
      tanggal: DateTime.parse(map['created_at']),
      namaLokasi: map['nama_kplt'] ?? ulokData['nama_ulok'] ?? '',
      alamat: map['alamat'] ?? ulokData['alamat'] ?? '',
      kecamatan: map['kecamatan'] ?? ulokData['kecamatan'] ?? '',
      desaKelurahan: map['desa_kelurahan'] ?? ulokData['desa_kelurahan'] ?? '',
      kabupaten: map['kabupaten'] ?? ulokData['kabupaten'] ?? '',
      provinsi: map['provinsi'] ?? ulokData['provinsi'] ?? '',
      latLong: latLongValue,
      formatStore: map['format_store'] ?? ulokData['format_store'],
      bentukObjek: map['bentuk_objek'] ?? ulokData['bentuk_objek'],
      alasHak: map['alas_hak'] ?? ulokData['alas_hak'],
      jumlahLantai: _parseInt(map['jumlah_lantai']),
      lebarDepan: _parseDouble(map['lebar_depan']),
      panjang: _parseDouble(map['panjang']),
      luas: _parseDouble(map['luas']),
      hargaSewa: _parseDouble(map['harga_sewa']),
      namaPemilik: map['nama_pemilik'] ?? ulokData['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'] ?? ulokData['kontak_pemilik'],
      formUlok: map['form_ulok'] ?? ulokData['form_ulok'],
      approvalIntip: map['approval_intip_status'] ?? ulokData['approval_intip_status'],
      fileIntip: map['file_intip'] ?? ulokData['file_intip'],
      tanggalApprovalIntip: map['tanggal_approval_intip'] == null ? null : DateTime.parse(map['tanggal_approval_intip']),
      karakterLokasi: map['karakter_lokasi'],
      sosialEkonomi: map['sosial_ekonomi'],
      peStatus: map['pe_status'],
      skorFpl: _parseDouble(map['skor_fpl']),
      std: _parseDouble(map['std']),
      apc: _parseDouble(map['apc']),
      spd: _parseDouble(map['spd']),
      peRab: _parseDouble(map['pe_rab']),
      pdfFoto: map['pdf_foto'],
      countingKompetitor: map['counting_kompetitor'],
      pdfPembanding: map['pdf_pembanding'],
      pdfKks: map['pdf_kks'],
      excelFpl: map['excel_fpl'],
      excelPe: map['excel_pe'],
      pdfFormUkur: map['pdf_form_ukur'],
      videoTrafficSiang: map['video_traffic_siang'],
      videoTrafficMalam: map['video_traffic_malam'],
      video360Siang: map['video_360_siang'],
      video360Malam: map['video_360_malam'],
      petaCoverage: map['peta_coverage'],
      progressPercentage: _parseDouble(map['progress_percentage']),
      progressSteps: null,
    );
  }

  /// Factory #2: Untuk data dari ULOK murni (Need Input)
  factory FormKPLT.fromUlokMap(Map<String, dynamic> map) {
    final lat = _parseDouble(map['latitude']);
    final lon = _parseDouble(map['longitude']);
    String? latLongValue;
    if (lat != null && lon != null) {
      latLongValue = '$lat,$lon';
    }
    
    // Kode lainnya sudah benar
    return FormKPLT(
      id: map['id'],
      ulokId: map['id'],
      status: 'Need Input',
      tanggal: DateTime.parse(map['updated_at']),
      namaLokasi: map['nama_ulok'] ?? '',
      alamat: map['alamat'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      desaKelurahan: map['desa_kelurahan'] ?? '',
      kabupaten: map['kabupaten'] ?? '',
      provinsi: map['provinsi'] ?? '',
      latLong: latLongValue,
      formatStore: map['format_store'],
      bentukObjek: map['bentuk_objek'],
      alasHak: map['alas_hak'],
      jumlahLantai: _parseInt(map['jumlah_lantai']),
      lebarDepan: _parseDouble(map['lebar_depan']),
      panjang: _parseDouble(map['panjang']),
      luas: _parseDouble(map['luas']),
      hargaSewa: _parseDouble(map['harga_sewa']),
      namaPemilik: map['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'],
      formUlok: map['form_ulok'],
      approvalIntip: map['approval_intip_status'],
      fileIntip: map['file_intip'],
      tanggalApprovalIntip: map['tanggal_approval_intip'] == null ? null : DateTime.parse(map['tanggal_approval_intip']),
      karakterLokasi: null,
      sosialEkonomi: null,
      peStatus: null,
      skorFpl: null,
      std: null,
      apc: null,
      spd: null,
      peRab: null,
      pdfFoto: null,
      countingKompetitor: null,
      pdfPembanding: null,
      pdfKks: null,
      excelFpl: null,
      excelPe: null,
      pdfFormUkur: null,
      videoTrafficSiang: null,
      videoTrafficMalam: null,
      video360Siang: null,
      video360Malam: null,
      petaCoverage: null,
      progressPercentage: 0.0,
      progressSteps: null,
    );
  }

  /// Factory #3: Untuk data dari KPLT murni (Detail Screen)
  factory FormKPLT.fromKpltDetailMap(Map<String, dynamic> map) {
    final lat = _parseDouble(map['latitude']);
    final lon = _parseDouble(map['longitude']);
    String? latLongValue;
    if (lat != null && lon != null) {
      latLongValue = '$lat,$lon';
    }

    return FormKPLT(
      id: map['id'],
      ulokId: map['ulok_id'],
      status: map['kplt_approval'],
      tanggal: DateTime.parse(map['created_at']),
      namaLokasi: map['nama_kplt'] ?? '',
      alamat: map['alamat'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      desaKelurahan: map['desa_kelurahan'] ?? '',
      kabupaten: map['kabupaten'] ?? '',
      provinsi: map['provinsi'] ?? '',
      latLong: latLongValue,
      formatStore: map['format_store'],
      bentukObjek: map['bentuk_objek'],
      alasHak: map['alas_hak'],
      jumlahLantai: _parseInt(map['jumlah_lantai']),
      lebarDepan: _parseDouble(map['lebar_depan']),
      panjang: _parseDouble(map['panjang']),
      luas: _parseDouble(map['luas']),
      hargaSewa: _parseDouble(map['harga_sewa']),
      namaPemilik: map['nama_pemilik'],
      kontakPemilik: map['kontak_pemilik'],
      formUlok: map['form_ulok'],
      approvalIntip: map['approval_intip_status'],
      fileIntip: map['file_intip'],
      tanggalApprovalIntip: map['tanggal_approval_intip'] == null ? null : DateTime.parse(map['tanggal_approval_intip']),
      karakterLokasi: map['karakter_lokasi'],
      sosialEkonomi: map['sosial_ekonomi'],
      peStatus: map['pe_status'],
      skorFpl: _parseDouble(map['skor_fpl']),
      std: _parseDouble(map['std']),
      apc: _parseDouble(map['apc']),
      spd: _parseDouble(map['spd']),
      peRab: _parseDouble(map['pe_rab']),
      pdfFoto: map['pdf_foto'],
      countingKompetitor: map['counting_kompetitor'],
      pdfPembanding: map['pdf_pembanding'],
      pdfKks: map['pdf_kks'],
      excelFpl: map['excel_fpl'],
      excelPe: map['excel_pe'],
      pdfFormUkur: map['pdf_form_ukur'],
      videoTrafficSiang: map['video_traffic_siang'],
      videoTrafficMalam: map['video_traffic_malam'],
      video360Siang: map['video_360_siang'],
      video360Malam: map['video_360_malam'],
      petaCoverage: map['peta_coverage'],
      progressPercentage: _parseDouble(map['progress_percentage']),
      progressSteps: null,
    );
  }
}