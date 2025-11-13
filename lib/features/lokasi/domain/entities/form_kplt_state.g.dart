// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_kplt_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KpltFormStateImpl _$$KpltFormStateImplFromJson(Map<String, dynamic> json) =>
    _$KpltFormStateImpl(
      ulokId: json['ulokId'] as String,
      localId: json['localId'] as String,
      status:
          $enumDecodeNullable(_$KpltFormStatusEnumMap, json['status']) ??
          KpltFormStatus.initial,
      errorMessage: json['errorMessage'] as String?,
      branchId: json['branchId'] as String?,
      namaLokasi: json['namaLokasi'] as String?,
      latLng: const LatLngConverter().fromJson(
        json['latLng'] as Map<String, double>?,
      ),
      provinsi: json['provinsi'] as String?,
      kabupaten: json['kabupaten'] as String?,
      kecamatan: json['kecamatan'] as String?,
      desaKelurahan: json['desaKelurahan'] as String?,
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
      karakterLokasi: json['karakterLokasi'] as String?,
      sosialEkonomi: json['sosialEkonomi'] as String?,
      peStatus: json['peStatus'] as String?,
      skorFpl: (json['skorFpl'] as num?)?.toDouble(),
      std: (json['std'] as num?)?.toDouble(),
      apc: (json['apc'] as num?)?.toDouble(),
      spd: (json['spd'] as num?)?.toDouble(),
      peRab: (json['peRab'] as num?)?.toDouble(),
      pdfFoto: const FilePathConverter().fromJson(json['pdfFoto'] as String?),
      countingKompetitor: const FilePathConverter().fromJson(
        json['countingKompetitor'] as String?,
      ),
      pdfPembanding: const FilePathConverter().fromJson(
        json['pdfPembanding'] as String?,
      ),
      pdfKks: const FilePathConverter().fromJson(json['pdfKks'] as String?),
      excelFpl: const FilePathConverter().fromJson(json['excelFpl'] as String?),
      excelPe: const FilePathConverter().fromJson(json['excelPe'] as String?),
      videoTrafficSiang: const FilePathConverter().fromJson(
        json['videoTrafficSiang'] as String?,
      ),
      videoTrafficMalam: const FilePathConverter().fromJson(
        json['videoTrafficMalam'] as String?,
      ),
      video360Siang: const FilePathConverter().fromJson(
        json['video360Siang'] as String?,
      ),
      video360Malam: const FilePathConverter().fromJson(
        json['video360Malam'] as String?,
      ),
      petaCoverage: const FilePathConverter().fromJson(
        json['petaCoverage'] as String?,
      ),
      existingPdfFotoPath: json['existingPdfFotoPath'] as String?,
      existingCountingKompetitorPath:
          json['existingCountingKompetitorPath'] as String?,
      existingPdfPembandingPath: json['existingPdfPembandingPath'] as String?,
      existingPdfKksPath: json['existingPdfKksPath'] as String?,
      existingExcelFplPath: json['existingExcelFplPath'] as String?,
      existingExcelPePath: json['existingExcelPePath'] as String?,
      existingVideoTrafficSiangPath:
          json['existingVideoTrafficSiangPath'] as String?,
      existingVideoTrafficMalamPath:
          json['existingVideoTrafficMalamPath'] as String?,
      existingVideo360SiangPath: json['existingVideo360SiangPath'] as String?,
      existingVideo360MalamPath: json['existingVideo360MalamPath'] as String?,
      existingPetaCoveragePath: json['existingPetaCoveragePath'] as String?,
      lastEdited: const DateTimeIsoConverter().fromJson(
        json['lastEdited'] as String?,
      ),
    );

Map<String, dynamic> _$$KpltFormStateImplToJson(_$KpltFormStateImpl instance) =>
    <String, dynamic>{
      'ulokId': instance.ulokId,
      'localId': instance.localId,
      'status': _$KpltFormStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'branchId': instance.branchId,
      'namaLokasi': instance.namaLokasi,
      'latLng': const LatLngConverter().toJson(instance.latLng),
      'provinsi': instance.provinsi,
      'kabupaten': instance.kabupaten,
      'kecamatan': instance.kecamatan,
      'desaKelurahan': instance.desaKelurahan,
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
      'karakterLokasi': instance.karakterLokasi,
      'sosialEkonomi': instance.sosialEkonomi,
      'peStatus': instance.peStatus,
      'skorFpl': instance.skorFpl,
      'std': instance.std,
      'apc': instance.apc,
      'spd': instance.spd,
      'peRab': instance.peRab,
      'pdfFoto': const FilePathConverter().toJson(instance.pdfFoto),
      'countingKompetitor': const FilePathConverter().toJson(
        instance.countingKompetitor,
      ),
      'pdfPembanding': const FilePathConverter().toJson(instance.pdfPembanding),
      'pdfKks': const FilePathConverter().toJson(instance.pdfKks),
      'excelFpl': const FilePathConverter().toJson(instance.excelFpl),
      'excelPe': const FilePathConverter().toJson(instance.excelPe),
      'videoTrafficSiang': const FilePathConverter().toJson(
        instance.videoTrafficSiang,
      ),
      'videoTrafficMalam': const FilePathConverter().toJson(
        instance.videoTrafficMalam,
      ),
      'video360Siang': const FilePathConverter().toJson(instance.video360Siang),
      'video360Malam': const FilePathConverter().toJson(instance.video360Malam),
      'petaCoverage': const FilePathConverter().toJson(instance.petaCoverage),
      'existingPdfFotoPath': instance.existingPdfFotoPath,
      'existingCountingKompetitorPath': instance.existingCountingKompetitorPath,
      'existingPdfPembandingPath': instance.existingPdfPembandingPath,
      'existingPdfKksPath': instance.existingPdfKksPath,
      'existingExcelFplPath': instance.existingExcelFplPath,
      'existingExcelPePath': instance.existingExcelPePath,
      'existingVideoTrafficSiangPath': instance.existingVideoTrafficSiangPath,
      'existingVideoTrafficMalamPath': instance.existingVideoTrafficMalamPath,
      'existingVideo360SiangPath': instance.existingVideo360SiangPath,
      'existingVideo360MalamPath': instance.existingVideo360MalamPath,
      'existingPetaCoveragePath': instance.existingPetaCoveragePath,
      'lastEdited': const DateTimeIsoConverter().toJson(instance.lastEdited),
    };

const _$KpltFormStatusEnumMap = {
  KpltFormStatus.initial: 'initial',
  KpltFormStatus.loading: 'loading',
  KpltFormStatus.success: 'success',
  KpltFormStatus.error: 'error',
};
