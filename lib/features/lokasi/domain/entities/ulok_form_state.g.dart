// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ulok_form_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UlokFormStateImpl _$$UlokFormStateImplFromJson(Map<String, dynamic> json) =>
    _$UlokFormStateImpl(
      ulokId: json['ulokId'] as String?,
      localId: json['localId'] as String,
      status:
          $enumDecodeNullable(_$UlokFormStatusEnumMap, json['status']) ??
          UlokFormStatus.initial,
      errorMessage: json['errorMessage'] as String?,
      namaUlok: json['namaUlok'] as String?,
      latLng: const LatLngConverter().fromJson(
        json['latLng'] as Map<String, double>?,
      ),
      provinsi: json['provinsi'] as String?,
      kabupaten: json['kabupaten'] as String?,
      kecamatan: json['kecamatan'] as String?,
      desa: json['desa'] as String?,
      alamat: json['alamat'] as String?,
      formatStore: json['formatStore'] as String?,
      bentukObjek: json['bentukObjek'] as String?,
      alasHak: json['alasHak'] as String?,
      jumlahLantai: (json['jumlahLantai'] as num?)?.toInt(),
      lebarDepan: (json['lebarDepan'] as num?)?.toDouble(),
      panjang: (json['panjang'] as num?)?.toDouble(),
      luas: (json['luas'] as num?)?.toDouble(),
      hargaSewa: (json['hargaSewa'] as num?)?.toDouble(),
      namaPemilik: json['namaPemilik'] as String?,
      kontakPemilik: json['kontakPemilik'] as String?,
      formUlokPdf: const FilePathConverter().fromJson(
        json['formUlokPdf'] as String?,
      ),
      existingFormUlokUrl: json['existingFormUlokUrl'] as String?,
      lastEdited: const DateTimeIsoConverter().fromJson(
        json['lastEdited'] as String?,
      ),
    );

Map<String, dynamic> _$$UlokFormStateImplToJson(_$UlokFormStateImpl instance) =>
    <String, dynamic>{
      'ulokId': instance.ulokId,
      'localId': instance.localId,
      'status': _$UlokFormStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'namaUlok': instance.namaUlok,
      'latLng': const LatLngConverter().toJson(instance.latLng),
      'provinsi': instance.provinsi,
      'kabupaten': instance.kabupaten,
      'kecamatan': instance.kecamatan,
      'desa': instance.desa,
      'alamat': instance.alamat,
      'formatStore': instance.formatStore,
      'bentukObjek': instance.bentukObjek,
      'alasHak': instance.alasHak,
      'jumlahLantai': instance.jumlahLantai,
      'lebarDepan': instance.lebarDepan,
      'panjang': instance.panjang,
      'luas': instance.luas,
      'hargaSewa': instance.hargaSewa,
      'namaPemilik': instance.namaPemilik,
      'kontakPemilik': instance.kontakPemilik,
      'formUlokPdf': const FilePathConverter().toJson(instance.formUlokPdf),
      'existingFormUlokUrl': instance.existingFormUlokUrl,
      'lastEdited': const DateTimeIsoConverter().toJson(instance.lastEdited),
    };

const _$UlokFormStatusEnumMap = {
  UlokFormStatus.initial: 'initial',
  UlokFormStatus.loading: 'loading',
  UlokFormStatus.success: 'success',
  UlokFormStatus.error: 'error',
};
