import 'dart:io';

import 'package:latlong2/latlong.dart';

class KpltFormData {
  final String ulokId;
  final String branchId;
  final String karakterLokasi;
  final String sosialEkonomi;
  final String peStatus;
  final double skorFpl;
  final double std;
  final double apc;
  final double spd;
  final double peRab;
  final File pdfFoto;
  final File countingKompetitor;
  final File pdfPembanding;
  final File pdfKks;
  final File excelFpl;
  final File excelPe;
  final File pdfFormUkur;
  final File videoTrafficSiang;
  final File videoTrafficMalam;
  final File video360Siang;
  final File video360Malam;
  final File petaCoverage;
  final String namaKplt;
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
  final String formUlok;
  final String approvalIntip;
  final DateTime tanggalApprovalIntip;
  final String fileIntip;

  KpltFormData({
    required this.ulokId,
    required this.branchId,
    required this.karakterLokasi,
    required this.sosialEkonomi,
    required this.peStatus,
    required this.skorFpl,
    required this.std,
    required this.apc,
    required this.spd,
    required this.peRab,
    required this.pdfFoto,
    required this.pdfFormUkur,
    required this.pdfPembanding,
    required this.pdfKks,
    required this.excelFpl,
    required this.excelPe,
    required this.countingKompetitor,
    required this.videoTrafficSiang,
    required this.videoTrafficMalam,
    required this.video360Siang,
    required this.video360Malam,
    required this.petaCoverage,
    required this.namaKplt,
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
    required this.approvalIntip,
    required this.tanggalApprovalIntip,
    required this.fileIntip,
    required this.formUlok
  });
}