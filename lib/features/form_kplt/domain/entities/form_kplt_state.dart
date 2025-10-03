import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';

enum KpltFormStatus { initial, loading, success, error }

class KpltFormState extends Equatable {
  final KpltFormStatus status;
  final String? errorMessage;
  final String ulokId;
  final String? branchId;
  final String? namaLokasi;
  final String? alamat;
  final String? provinsi;
  final String? kabupaten;
  final String? kecamatan;
  final String? desaKelurahan;
  final LatLng? latLng;
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
  final String? karakterLokasi;
  final String? sosialEkonomi;
  final String? peStatus;
  final double? skorFpl;
  final double? std;
  final double? apc;
  final double? spd;
  final double? peRab;
  final File? pdfFoto;
  final File? countingKompetitor;
  final File? pdfPembanding;
  final File? pdfKks;
  final File? excelFpl;
  final File? excelPe;
  final File? pdfFormUkur;
  final File? videoTrafficSiang;
  final File? videoTrafficMalam;
  final File? video360Siang;
  final File? video360Malam;
  final File? petaCoverage;
  final String? existingPdfFotoPath;
  final String? existingCountingKompetitorPath;
  final String? existingPdfPembandingPath;
  final String? existingPdfKksPath;
  final String? existingExcelFplPath;
  final String? existingExcelPePath;
  final String? existingPdfFormUkurPath;
  final String? existingVideoTrafficSiangPath;
  final String? existingVideoTrafficMalamPath;
  final String? existingVideo360SiangPath;
  final String? existingVideo360MalamPath;
  final String? existingPetaCoveragePath;

  const KpltFormState({
    required this.status,
    required this.ulokId,
    this.errorMessage,
    this.branchId,
    this.namaLokasi,
    this.alamat,
    this.provinsi,
    this.kabupaten,
    this.kecamatan,
    this.desaKelurahan,
    this.latLng,
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
    this.existingPdfFotoPath,
    this.existingCountingKompetitorPath,
    this.existingPdfPembandingPath,
    this.existingPdfKksPath,
    this.existingExcelFplPath,
    this.existingExcelPePath,
    this.existingPdfFormUkurPath,
    this.existingVideoTrafficSiangPath,
    this.existingVideoTrafficMalamPath,
    this.existingVideo360SiangPath,
    this.existingVideo360MalamPath,
    this.existingPetaCoveragePath,
  });

  factory KpltFormState.initial({required String ulokId}) {
    return KpltFormState(status: KpltFormStatus.initial, ulokId: ulokId);
  }

  KpltFormState copyWith({
    KpltFormStatus? status,
    String? errorMessage,
    String? branchId,
    String? namaLokasi,
    String? alamat,
    String? provinsi,
    String? kabupaten,
    String? kecamatan,
    String? desaKelurahan,
    LatLng? latLng,
    String? formatStore,
    String? bentukObjek,
    String? alasHak,
    int? jumlahLantai,
    double? lebarDepan,
    double? panjang,
    double? luas,
    double? hargaSewa,
    String? namaPemilik,
    String? kontakPemilik,
    String? karakterLokasi,
    String? sosialEkonomi,
    String? peStatus,
    double? skorFpl,
    double? std,
    double? apc,
    double? spd,
    double? peRab,
    File? pdfFoto,
    File? countingKompetitor,
    File? pdfPembanding,
    File? pdfKks,
    File? excelFpl,
    File? excelPe,
    File? pdfFormUkur,
    File? videoTrafficSiang,
    File? videoTrafficMalam,
    File? video360Siang,
    File? video360Malam,
    File? petaCoverage,
    String? existingPdfFotoPath,
    String? existingCountingKompetitorPath,
    String? existingPdfPembandingPath,
    String? existingPdfKksPath,
    String? existingExcelFplPath,
    String? existingExcelPePath,
    String? existingPdfFormUkurPath,
    String? existingVideoTrafficSiangPath,
    String? existingVideoTrafficMalamPath,
    String? existingVideo360SiangPath,
    String? existingVideo360MalamPath,
    String? existingPetaCoveragePath,
  }) {
    return KpltFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      ulokId: ulokId,
      branchId: branchId ?? this.branchId,
      namaLokasi: namaLokasi ?? this.namaLokasi,
      alamat: alamat ?? this.alamat,
      provinsi: provinsi ?? this.provinsi,
      kabupaten: kabupaten ?? this.kabupaten,
      kecamatan: kecamatan ?? this.kecamatan,
      desaKelurahan: desaKelurahan ?? this.desaKelurahan,
      latLng: latLng ?? this.latLng,
      formatStore: formatStore ?? this.formatStore,
      bentukObjek: bentukObjek ?? this.bentukObjek,
      alasHak: alasHak ?? this.alasHak,
      jumlahLantai: jumlahLantai ?? this.jumlahLantai,
      lebarDepan: lebarDepan ?? this.lebarDepan,
      panjang: panjang ?? this.panjang,
      luas: luas ?? this.luas,
      hargaSewa: hargaSewa ?? this.hargaSewa,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      kontakPemilik: kontakPemilik ?? this.kontakPemilik,
      karakterLokasi: karakterLokasi ?? this.karakterLokasi,
      sosialEkonomi: sosialEkonomi ?? this.sosialEkonomi,
      peStatus: peStatus ?? this.peStatus,
      skorFpl: skorFpl ?? this.skorFpl,
      std: std ?? this.std,
      apc: apc ?? this.apc,
      spd: spd ?? this.spd,
      peRab: peRab ?? this.peRab,
      pdfFoto: pdfFoto ?? this.pdfFoto,
      countingKompetitor: countingKompetitor ?? this.countingKompetitor,
      pdfPembanding: pdfPembanding ?? this.pdfPembanding,
      pdfKks: pdfKks ?? this.pdfKks,
      excelFpl: excelFpl ?? this.excelFpl,
      excelPe: excelPe ?? this.excelPe,
      pdfFormUkur: pdfFormUkur ?? this.pdfFormUkur,
      videoTrafficSiang: videoTrafficSiang ?? this.videoTrafficSiang,
      videoTrafficMalam: videoTrafficMalam ?? this.videoTrafficMalam,
      video360Siang: video360Siang ?? this.video360Siang,
      video360Malam: video360Malam ?? this.video360Malam,
      petaCoverage: petaCoverage ?? this.petaCoverage,
      existingPdfFotoPath: existingPdfFotoPath ?? this.existingPdfFotoPath,
      existingCountingKompetitorPath: existingCountingKompetitorPath ?? this.existingCountingKompetitorPath,
      existingPdfPembandingPath: existingPdfPembandingPath ?? this.existingPdfPembandingPath,
      existingPdfKksPath: existingPdfKksPath ?? this.existingPdfKksPath,
      existingExcelFplPath: existingExcelFplPath ?? this.existingExcelFplPath,
      existingExcelPePath: existingExcelPePath ?? this.existingExcelPePath,
      existingPdfFormUkurPath: existingPdfFormUkurPath ?? this.existingPdfFormUkurPath,
      existingVideoTrafficSiangPath: existingVideoTrafficSiangPath ?? this.existingVideoTrafficSiangPath,
      existingVideoTrafficMalamPath: existingVideoTrafficMalamPath ?? this.existingVideoTrafficMalamPath,
      existingVideo360SiangPath: existingVideo360SiangPath ?? this.existingVideo360SiangPath,
      existingVideo360MalamPath: existingVideo360MalamPath ?? this.existingVideo360MalamPath,
      existingPetaCoveragePath: existingPetaCoveragePath ?? this.existingPetaCoveragePath,
    );
  }

  factory KpltFormState.fromFormKPLT(FormKPLT kplt) {
    final latLngParts = kplt.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(double.tryParse(latLngParts[0]) ?? 0.0, double.tryParse(latLngParts[1]) ?? 0.0);

    return KpltFormState(
      status: KpltFormStatus.initial,
      ulokId: kplt.ulokId,
      namaLokasi: kplt.namaLokasi,
      alamat: kplt.alamat,
      provinsi: kplt.provinsi,
      kabupaten: kplt.kabupaten,
      kecamatan: kplt.kecamatan,
      desaKelurahan: kplt.desaKelurahan,
      latLng: latLng,
      formatStore: kplt.formatStore,
      bentukObjek: kplt.bentukObjek,
      alasHak: kplt.alasHak,
      jumlahLantai: kplt.jumlahLantai,
      lebarDepan: kplt.lebarDepan,
      panjang: kplt.panjang,
      luas: kplt.luas,
      hargaSewa: kplt.hargaSewa,
      namaPemilik: kplt.namaPemilik,
      kontakPemilik: kplt.kontakPemilik,
      karakterLokasi: kplt.karakterLokasi,
      sosialEkonomi: kplt.sosialEkonomi,
      peStatus: kplt.peStatus,
      skorFpl: kplt.skorFpl,
      std: kplt.std,
      apc: kplt.apc,
      spd: kplt.spd,
      peRab: kplt.peRab,
      existingPdfFotoPath: kplt.pdfFoto,
      existingCountingKompetitorPath: kplt.countingKompetitor,
      existingPdfPembandingPath: kplt.pdfPembanding,
      existingPdfKksPath: kplt.pdfKks,
      existingExcelFplPath: kplt.excelFpl,
      existingExcelPePath: kplt.excelPe,
      existingPdfFormUkurPath: kplt.pdfFormUkur,
      existingVideoTrafficSiangPath: kplt.videoTrafficSiang,
      existingVideoTrafficMalamPath: kplt.videoTrafficMalam,
      existingVideo360SiangPath: kplt.video360Siang,
      existingVideo360MalamPath: kplt.video360Malam,
      existingPetaCoveragePath: kplt.petaCoverage,
    );
  }

  @override
  List<Object?> get props => [
        status, errorMessage, ulokId, branchId, namaLokasi, alamat, provinsi,
        kabupaten, kecamatan, desaKelurahan, latLng, formatStore, bentukObjek,
        alasHak, jumlahLantai, lebarDepan, panjang, luas, hargaSewa, namaPemilik,
        kontakPemilik, karakterLokasi, sosialEkonomi, peStatus, skorFpl, std,
        apc, spd, peRab, pdfFoto, countingKompetitor, pdfPembanding, pdfKks,
        excelFpl, excelPe, pdfFormUkur, videoTrafficSiang, videoTrafficMalam,
        video360Siang, video360Malam, petaCoverage, existingPdfFotoPath,
        existingCountingKompetitorPath, existingPdfPembandingPath, existingPdfKksPath,
        existingExcelFplPath, existingExcelPePath, existingPdfFormUkurPath,
        existingVideoTrafficSiangPath, existingVideoTrafficMalamPath,
        existingVideo360SiangPath, existingVideo360MalamPath, existingPetaCoveragePath,
      ];

  Map<String, dynamic> toJson() {
    return {
      'ulokId': ulokId,
      'branchId': branchId,
      'namaLokasi': namaLokasi,
      'alamat': alamat,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'desaKelurahan': desaKelurahan,
      'latitude': latLng?.latitude,
      'longitude': latLng?.longitude,
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
      'karakterLokasi': karakterLokasi,
      'sosialEkonomi': sosialEkonomi,
      'peStatus': peStatus,
      'skorFpl': skorFpl,
      'std': std,
      'apc': apc,
      'spd': spd,
      'peRab': peRab,
      'pdfFotoPath': pdfFoto?.path,
      'countingKompetitorPath': countingKompetitor?.path,
      'pdfPembandingPath': pdfPembanding?.path,
      'pdfKksPath': pdfKks?.path,
      'excelFplPath': excelFpl?.path,
      'excelPePath': excelPe?.path,
      'pdfFormUkurPath': pdfFormUkur?.path,
      'videoTrafficSiangPath': videoTrafficSiang?.path,
      'videoTrafficMalamPath': videoTrafficMalam?.path,
      'video360SiangPath': video360Siang?.path,
      'video360MalamPath': video360Malam?.path,
      'petaCoveragePath': petaCoverage?.path,
      'existingPdfFotoPath': existingPdfFotoPath,
      'existingCountingKompetitorPath': existingCountingKompetitorPath,
      'existingPdfPembandingPath': existingPdfPembandingPath,
      'existingPdfKksPath': existingPdfKksPath,
      'existingExcelFplPath': existingExcelFplPath,
      'existingExcelPePath': existingExcelPePath,
      'existingPdfFormUkurPath': existingPdfFormUkurPath,
      'existingVideoTrafficSiangPath': existingVideoTrafficSiangPath,
      'existingVideoTrafficMalamPath': existingVideoTrafficMalamPath,
      'existingVideo360SiangPath': existingVideo360SiangPath,
      'existingVideo360MalamPath': existingVideo360MalamPath,
      'existingPetaCoveragePath': existingPetaCoveragePath,
    };
  }
  
  factory KpltFormState.fromJson(Map<String, dynamic> json) {
    return KpltFormState(
      status: KpltFormStatus.initial,
      ulokId: json['ulokId'],
      branchId: json['branchId'],
      namaLokasi: json['namaLokasi'],
      alamat: json['alamat'],
      provinsi: json['provinsi'],
      kabupaten: json['kabupaten'],
      kecamatan: json['kecamatan'],
      desaKelurahan: json['desaKelurahan'],
      latLng: (json['latitude'] != null && json['longitude'] != null)
          ? LatLng(json['latitude'], json['longitude'])
          : null,
      formatStore: json['formatStore'],
      bentukObjek: json['bentukObjek'],
      alasHak: json['alasHak'],
      jumlahLantai: json['jumlahLantai'],
      lebarDepan: json['lebarDepan'],
      panjang: json['panjang'],
      luas: json['luas'],
      hargaSewa: json['hargaSewa'],
      namaPemilik: json['namaPemilik'],
      kontakPemilik: json['kontakPemilik'],
      karakterLokasi: json['karakterLokasi'],
      sosialEkonomi: json['sosialEkonomi'],
      peStatus: json['peStatus'],
      skorFpl: json['skorFpl'],
      std: json['std'],
      apc: json['apc'],
      spd: json['spd'],
      peRab: json['peRab'],
      pdfFoto: json['pdfFotoPath'] != null ? File(json['pdfFotoPath']) : null,
      countingKompetitor: json['countingKompetitorPath'] != null ? File(json['countingKompetitorPath']) : null,
      pdfPembanding: json['pdfPembandingPath'] != null ? File(json['pdfPembandingPath']) : null,
      pdfKks: json['pdfKksPath'] != null ? File(json['pdfKksPath']) : null,
      excelFpl: json['excelFplPath'] != null ? File(json['excelFplPath']) : null,
      excelPe: json['excelPePath'] != null ? File(json['excelPePath']) : null,
      pdfFormUkur: json['pdfFormUkurPath'] != null ? File(json['pdfFormUkurPath']) : null,
      videoTrafficSiang: json['videoTrafficSiangPath'] != null ? File(json['videoTrafficSiangPath']) : null,
      videoTrafficMalam: json['videoTrafficMalamPath'] != null ? File(json['videoTrafficMalamPath']) : null,
      video360Siang: json['video360SiangPath'] != null ? File(json['video360SiangPath']) : null,
      video360Malam: json['video360MalamPath'] != null ? File(json['video360MalamPath']) : null,
      petaCoverage: json['petaCoveragePath'] != null ? File(json['petaCoveragePath']) : null,
      existingPdfFotoPath: json['existingPdfFotoPath'],
      existingCountingKompetitorPath: json['existingCountingKompetitorPath'],
      existingPdfPembandingPath: json['existingPdfPembandingPath'],
      existingPdfKksPath: json['existingPdfKksPath'],
      existingExcelFplPath: json['existingExcelFplPath'],
      existingExcelPePath: json['existingExcelPePath'],
      existingPdfFormUkurPath: json['existingPdfFormUkurPath'],
      existingVideoTrafficSiangPath: json['existingVideoTrafficSiangPath'],
      existingVideoTrafficMalamPath: json['existingVideoTrafficMalamPath'],
      existingVideo360SiangPath: json['existingVideo360SiangPath'],
      existingVideo360MalamPath: json['existingVideo360MalamPath'],
      existingPetaCoveragePath: json['existingPetaCoveragePath'],
    );
  }
}