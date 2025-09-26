import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:uuid/uuid.dart';

enum UlokFormStatus { initial, loading, success, error }

class UlokFormState extends Equatable{
  final String? ulokId;
  final String localId;
  final UlokFormStatus status;
  final String? errorMessage;
  final String? namaUlok;
  final LatLng? latLng;
  final String? provinsi;
  final String? kabupaten;
  final String? kecamatan;
  final String? desa;
  final String? alamat;
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
  final File? formUlokPdf;
  final String? existingFormUlokUrl;

  const UlokFormState({
    this.ulokId,
    required this.localId,
    this.status = UlokFormStatus.initial,
    this.errorMessage,
    this.namaUlok,
    this.latLng,
    this.provinsi,
    this.kabupaten,
    this.kecamatan,
    this.desa,
    this.alamat,
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
    this.formUlokPdf,
    this.existingFormUlokUrl,
  });

  UlokFormState copyWith({
    String? ulokId,
    String? localId,
    UlokFormStatus? status,
    String? errorMessage,
    String? namaUlok,
    LatLng? latLng,
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
    File? formUlokPdf,
    String? existingFormUlokUrl,
  }) {
    return UlokFormState(
      ulokId: ulokId ?? this.ulokId,
      localId: localId ?? this.localId,
      status: status ?? this.status,
      errorMessage: errorMessage,
      namaUlok: namaUlok ?? this.namaUlok,
      latLng: latLng ?? this.latLng,
      provinsi: provinsi ?? this.provinsi,
      kabupaten: kabupaten ?? this.kabupaten,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      alamat: alamat ?? this.alamat,
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
      formUlokPdf: formUlokPdf ?? this.formUlokPdf,
      existingFormUlokUrl: existingFormUlokUrl ?? this.existingFormUlokUrl,
    );
  }


Map<String, dynamic> toJson() {
    return {
      'ulokId': ulokId,
      'localId': localId,
      'namaUlok': namaUlok,
      'latitude': latLng?.latitude,
      'longitude': latLng?.longitude,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'desa': desa,
      'alamat': alamat,
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
      'formUlokPdfPath': formUlokPdf?.path,
    };
  }

  factory UlokFormState.fromJson(Map<String, dynamic> json) {
    return UlokFormState(
      ulokId: json['ulokId'],
      localId: json['localId'] ?? const Uuid().v4(),
      namaUlok: json['namaUlok'],
      latLng: (json['latitude'] != null && json['longitude'] != null)
          ? LatLng(json['latitude'], json['longitude'])
          : null,
      provinsi: json['provinsi'],
      kabupaten: json['kabupaten'],
      kecamatan: json['kecamatan'],
      desa: json['desa'],
      alamat: json['alamat'],
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
      formUlokPdf: json['formUlokPdfPath'] != null ? File(json['formUlokPdfPath']) : null,
    );
  }

  @override
  List<Object?> get props => [ulokId, localId, status, namaUlok, latLng,provinsi, kabupaten, kecamatan, desa, alamat, formatStore, bentukObjek, alasHak, jumlahLantai, lebarDepan, panjang, luas, hargaSewa, namaPemilik, kontakPemilik, formUlokPdf];

  factory UlokFormState.fromUsulanLokasi(UsulanLokasi ulok) {
    return UlokFormState(
      ulokId: ulok.id, 
      localId: Uuid().v4(), 
      namaUlok: ulok.namaLokasi,
      alamat: ulok.alamat,
      latLng: ulok.latLong != null ? LatLng(double.parse(ulok.latLong!.split(',')[0]), double.parse(ulok.latLong!.split(',')[1])) : null,
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
    );
  }
}