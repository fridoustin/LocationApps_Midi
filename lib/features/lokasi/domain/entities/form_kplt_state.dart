import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/utils/json_converters.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';
import 'package:uuid/uuid.dart';

part 'form_kplt_state.freezed.dart';
part 'form_kplt_state.g.dart';


enum KpltFormStatus { initial, loading, success, error }

@freezed
class KpltFormState with _$KpltFormState {
  const factory KpltFormState({
    required String ulokId,
    required String localId,
    @Default(KpltFormStatus.initial) KpltFormStatus status,
    String? errorMessage,
    String? branchId,
    String? namaLokasi,
    @LatLngConverter() LatLng? latLng,
    String? provinsi,
    String? kabupaten,
    String? kecamatan,
    String? desaKelurahan,
    String? alamat,
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
    @FilePathConverter() File? pdfFoto,
    @FilePathConverter() File? countingKompetitor,
    @FilePathConverter() File? pdfPembanding,
    @FilePathConverter() File? pdfKks,
    @FilePathConverter() File? excelFpl,
    @FilePathConverter() File? excelPe,
    @FilePathConverter() File? videoTrafficSiang,
    @FilePathConverter() File? videoTrafficMalam,
    @FilePathConverter() File? video360Siang,
    @FilePathConverter() File? video360Malam,
    @FilePathConverter() File? petaCoverage,
    String? existingPdfFotoPath,
    String? existingCountingKompetitorPath,
    String? existingPdfPembandingPath,
    String? existingPdfKksPath,
    String? existingExcelFplPath,
    String? existingExcelPePath,
    String? existingVideoTrafficSiangPath,
    String? existingVideoTrafficMalamPath,
    String? existingVideo360SiangPath,
    String? existingVideo360MalamPath,
    String? existingPetaCoveragePath,
    @DateTimeIsoConverter() DateTime? lastEdited,
  }) = _KpltFormState;
  factory KpltFormState.fromJson(Map<String, dynamic> json) =>
      _$KpltFormStateFromJson(json);
  factory KpltFormState.initial({required String ulokId}) {
    return KpltFormState(
      ulokId: ulokId,
      localId: const Uuid().v4(),
      status: KpltFormStatus.initial,
      lastEdited: null,
    );
  }
  factory KpltFormState.fromFormKPLT(FormKPLT kplt) {
    return KpltFormState(
      localId: const Uuid().v4(),
      status: KpltFormStatus.initial,
      ulokId: kplt.ulokId,
      namaLokasi: kplt.namaLokasi,
      alamat: kplt.alamat,
      provinsi: kplt.provinsi,
      kabupaten: kplt.kabupaten,
      kecamatan: kplt.kecamatan,
      desaKelurahan: kplt.desaKelurahan,
      latLng: kplt.latLong != null
          ? LatLng(
              double.parse(kplt.latLong!.split(',')[0]),
              double.parse(kplt.latLong!.split(',')[1]),
            )
          : null,
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
      existingVideoTrafficSiangPath: kplt.videoTrafficSiang,
      existingVideoTrafficMalamPath: kplt.videoTrafficMalam,
      existingVideo360SiangPath: kplt.video360Siang,
      existingVideo360MalamPath: kplt.video360Malam,
      existingPetaCoveragePath: kplt.petaCoverage,
      lastEdited: null, 
    );
  }
}