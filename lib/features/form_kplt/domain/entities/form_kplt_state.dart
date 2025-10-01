import 'dart:io';
import 'package:equatable/equatable.dart';

enum KpltFormStatus { initial, loading, success, error }

class KpltFormState extends Equatable {
  final KpltFormStatus status;
  final String? errorMessage;
  final String ulokId;
  final String? branchId;
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

  const KpltFormState({
    required this.status,
    required this.ulokId,
    this.errorMessage,
    this.branchId,
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
  });

  // State awal saat form pertama kali dibuka
  factory KpltFormState.initial({required String ulokId}) {
    return KpltFormState(status: KpltFormStatus.initial, ulokId: ulokId);
  }

  // Method copyWith untuk update state dengan mudah
  KpltFormState copyWith({
    KpltFormStatus? status,
    String? errorMessage,
    String? branchId,
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
  }) {
    return KpltFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      ulokId: ulokId,
      branchId: branchId ?? this.branchId,
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
    );
  }
  
  @override
  List<Object?> get props => [status, errorMessage, ulokId, branchId, karakterLokasi, sosialEkonomi, peStatus, skorFpl, std, apc, spd, peRab, pdfFoto, countingKompetitor, pdfPembanding, pdfKks, excelFpl, excelPe, pdfFormUkur, videoTrafficSiang, videoTrafficMalam, video360Siang, video360Malam, petaCoverage];
  
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'ulokId': ulokId,
      'branchId': branchId,
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
    };
  }

  // Membuat state dari Map (yang didapat dari JSON)
  factory KpltFormState.fromJson(Map<String, dynamic> json) {
    return KpltFormState(
      status: KpltFormStatus.initial,
      ulokId: json['ulokId'],
      branchId: json['branchId'],
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
    );
  }
}