import 'dart:io';

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
  });
}