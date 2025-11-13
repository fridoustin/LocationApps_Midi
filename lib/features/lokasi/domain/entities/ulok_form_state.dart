import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/utils/json_converters.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:uuid/uuid.dart';
part 'ulok_form_state.freezed.dart';
part 'ulok_form_state.g.dart';

enum UlokFormStatus { initial, loading, success, error }

@freezed
class UlokFormState with _$UlokFormState {
  const factory UlokFormState({
    String? ulokId,
    required String localId,
    @Default(UlokFormStatus.initial) UlokFormStatus status,
    String? errorMessage,
    String? namaUlok,
    @LatLngConverter() LatLng? latLng,
    String? provinsi,
    String? kabupaten,
    String? kecamatan,
    String? desa,
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
    @FilePathConverter() File? formUlokPdf,
    String? existingFormUlokUrl,
    @DateTimeIsoConverter() DateTime? lastEdited,
  }) = _UlokFormState;
  factory UlokFormState.fromJson(Map<String, dynamic> json) =>
      _$UlokFormStateFromJson(json);
  factory UlokFormState.fromUsulanLokasi(UsulanLokasi ulok) {
    return UlokFormState(
      ulokId: ulok.id,
      localId: const Uuid().v4(),
      namaUlok: ulok.namaLokasi,
      alamat: ulok.alamat,
      latLng: ulok.latLong != null
          ? LatLng(
              double.parse(ulok.latLong!.split(',')[0]),
              double.parse(ulok.latLong!.split(',')[1]),
            )
          : null,
      provinsi: ulok.provinsi,
      kabupaten: ulok.kabupaten,
      kecamatan: ulok.kecamatan,
      desa: ulok.desaKelurahan,
      formatStore: ulok.formatStore,
      bentukObjek: ulok.bentukObjek,
      alasHak: ulok.alasHak,
      jumlahLantai: ulok.jumlahLantai,
      lebarDepan: ulok.lebarDepan,
      panjang: ulok.panjang,
      luas: ulok.luas,
      hargaSewa: ulok.hargaSewa,
      namaPemilik: ulok.namaPemilik,
      kontakPemilik: ulok.kontakPemilik,
      existingFormUlokUrl: ulok.formUlok,
      lastEdited: DateTime.now(),
    );
  }
}