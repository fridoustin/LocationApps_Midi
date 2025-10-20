import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/data/datasources/kplt_draft_manager.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';

final kpltDraftManagerProvider = Provider((_) => KpltDraftManager());

class KpltFormNotifier extends StateNotifier<KpltFormState> {
  final KpltRepository _repository;
  final KpltDraftManager _draftManager; 
  final String _ulokId;
  final Ref _ref;

  KpltFormNotifier(this._repository, this._draftManager, this._ref,{required String ulokId, FormKPLT? initialData})
      : _ulokId = ulokId,
        super(initialData != null
              ? KpltFormState.fromFormKPLT(initialData)
              : KpltFormState.initial(ulokId: ulokId)) {
    if (initialData == null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final profile = await _ref.read(userProfileProvider.future);
    final branchId = profile?.branchId;
    final draft = await _draftManager.loadDraft(_ulokId);

    if (draft != null) {
      state = draft.copyWith(branchId: draft.branchId ?? branchId);
    } else {
      state = state.copyWith(branchId: branchId);
    }
  }

  void onNamaLokasiChanged(String value) => state = state.copyWith(namaLokasi: value);
  void onAlamatChanged(String value) => state = state.copyWith(alamat: value);
  void onProvinceSelected(WilayahEntity? province) => state = state.copyWith(provinsi: province?.name, kabupaten: null, kecamatan: null, desaKelurahan: null);
  void onRegencySelected(WilayahEntity? regency) => state = state.copyWith(kabupaten: regency?.name, kecamatan: null, desaKelurahan: null);
  void onDistrictSelected(WilayahEntity? district) => state = state.copyWith(kecamatan: district?.name, desaKelurahan: null);
  void onVillageSelected(WilayahEntity? village) => state = state.copyWith(desaKelurahan: village?.name);
  void onLatLngChanged(LatLng value) => state = state.copyWith(latLng: value);
  void onFormatStoreChanged(String value) => state = state.copyWith(formatStore: value);
  void onBentukObjekChanged(String value) => state = state.copyWith(bentukObjek: value);
  void onAlasHakChanged(String value) => state = state.copyWith(alasHak: value);
  void onJumlahLantaiChanged(String value) => state = state.copyWith(jumlahLantai: int.tryParse(value));
  void onLebarDepanChanged(String value) => state = state.copyWith(lebarDepan: double.tryParse(value));
  void onPanjangChanged(String value) => state = state.copyWith(panjang: double.tryParse(value));
  void onLuasChanged(String value) => state = state.copyWith(luas: double.tryParse(value));
  void onHargaSewaChanged(String value) => state = state.copyWith(hargaSewa: double.tryParse(value));
  void onNamaPemilikChanged(String value) => state = state.copyWith(namaPemilik: value);
  void onKontakPemilikChanged(String value) => state = state.copyWith(kontakPemilik: value);
  void onKarakterLokasiChanged(String value) => state = state.copyWith(karakterLokasi: value);
  void onSosialEkonomiChanged(String value) => state = state.copyWith(sosialEkonomi: value);
  void onPeStatusChanged(String value) => state = state.copyWith(peStatus: value);
  void onSkorFplChanged(String value) => state = state.copyWith(skorFpl: double.tryParse(value));
  void onStdChanged(String value) => state = state.copyWith(std: double.tryParse(value));
  void onApcChanged(String value) => state = state.copyWith(apc: double.tryParse(value));
  void onSpdChanged(String value) => state = state.copyWith(spd: double.tryParse(value));
  void onPeRabChanged(String value) => state = state.copyWith(peRab: double.tryParse(value));


  void onFilePicked(String fieldName, File file) {
    switch (fieldName) {
      case 'pdfFoto':
        state = state.copyWith(pdfFoto: file);
        break;
      case 'countingKompetitor':
        state = state.copyWith(countingKompetitor: file);
        break;
      case 'pdfPembanding':
        state = state.copyWith(pdfPembanding: file);
        break;
      case 'pdfKks':
        state = state.copyWith(pdfKks: file);
        break;
      case 'excelFpl':
        state = state.copyWith(excelFpl: file);
        break;
      case 'excelPe':
        state = state.copyWith(excelPe: file);
        break;
      case 'pdfFormUkur':
        state = state.copyWith(pdfFormUkur: file);
        break;
      case 'videoTrafficSiang':
        state = state.copyWith(videoTrafficSiang: file);
        break;
      case 'videoTrafficMalam':
        state = state.copyWith(videoTrafficMalam: file);
        break;
      case 'video360Siang':
        state = state.copyWith(video360Siang: file);
        break;
      case 'video360Malam':
        state = state.copyWith(video360Malam: file);
        break;
      case 'petaCoverage':
        state = state.copyWith(petaCoverage: file);
        break;
    }
  }

  Future<bool> saveDraft() async {
    try {
      await _draftManager.saveDraft(state);
      return true; // Kembalikan true jika sukses
    } catch (e) {
      // Handle error jika perlu
      return false; // Kembalikan false jika gagal
    }
  }

  // --- Method utama untuk submit form ---
  Future<bool> submitForm() async {
    debugPrint("--- CHECKING STATE ON SUBMIT ---");
    debugPrint(state.toJson().toString());
    final s = state; 
    if (s.branchId == null || s.karakterLokasi == null || s.sosialEkonomi == null ||
        s.peStatus == null || s.skorFpl == null || s.std == null || s.apc == null ||
        s.spd == null || s.peRab == null || s.pdfFoto == null || s.countingKompetitor == null ||
        s.pdfPembanding == null || s.pdfKks == null || s.excelFpl == null || s.excelPe == null ||
        s.pdfFormUkur == null || s.videoTrafficSiang == null || s.videoTrafficMalam == null ||
        s.video360Siang == null || s.video360Malam == null || s.petaCoverage == null)
    {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: 'Harap lengkapi semua data.');
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(status: KpltFormStatus.initial, errorMessage: null);
      return false;
    }

    state = state.copyWith(status: KpltFormStatus.loading);

    try {
      final ulokDetail = await _ref.read(ulokByIdProvider(_ulokId).future);

      if (ulokDetail.latLong == null || ulokDetail.latLong!.isEmpty) {
        throw Exception('Data Latitude/Longitude dari ULOK tidak ditemukan.');
      }

      final parts = ulokDetail.latLong!.split(',');
      if (parts.length != 2) {
        throw Exception('Format Latitude/Longitude tidak valid.');
      }

      final latLngObject = LatLng(
        double.parse(parts[0].trim()), 
        double.parse(parts[1].trim()), 
      );

      final formData = KpltFormData(
        ulokId: s.ulokId,
        branchId: s.branchId!,
        karakterLokasi: s.karakterLokasi!,
        sosialEkonomi: s.sosialEkonomi!,
        peStatus: s.peStatus!,
        skorFpl: s.skorFpl!,
        std: s.std!,
        apc: s.apc!,
        spd: s.spd!,
        peRab: s.peRab!,
        pdfFoto: s.pdfFoto!,
        countingKompetitor: s.countingKompetitor!,
        pdfPembanding: s.pdfPembanding!,
        pdfKks: s.pdfKks!,
        excelFpl: s.excelFpl!,
        excelPe: s.excelPe!,
        pdfFormUkur: s.pdfFormUkur!,
        videoTrafficSiang: s.videoTrafficSiang!,
        videoTrafficMalam: s.videoTrafficMalam!,
        video360Siang: s.video360Siang!,
        video360Malam: s.video360Malam!,
        petaCoverage: s.petaCoverage!,
        namaKplt: ulokDetail.namaLokasi,
        provinsi: ulokDetail.provinsi,
        kabupaten: ulokDetail.kabupaten,
        kecamatan: ulokDetail.kecamatan,
        desa: ulokDetail.desaKelurahan,
        alamat: ulokDetail.alamat,
        latLng: latLngObject,
        formatStore: ulokDetail.formatStore!,
        bentukObjek: ulokDetail.bentukObjek!,
        alasHak: ulokDetail.alasHak!,
        jumlahLantai: ulokDetail.jumlahLantai!,
        lebarDepan: ulokDetail.lebarDepan!,
        panjang: ulokDetail.panjang!,
        luas: ulokDetail.luas!,
        hargaSewa: ulokDetail.hargaSewa!,
        namaPemilik: ulokDetail.namaPemilik!,
        kontakPemilik: ulokDetail.kontakPemilik!,
        approvalIntip: ulokDetail.approvalIntip!,
        tanggalApprovalIntip: ulokDetail.tanggalApprovalIntip!,
        fileIntip: ulokDetail.fileIntip!,
        formUlok: ulokDetail.formUlok!
      );

      await _repository.submitKplt(formData);
      await _draftManager.deleteDraft(_ulokId);

      final _ = await _ref.refresh(kpltNeedInputProvider.future);
      final _ = await _ref.refresh(kpltInProgressProvider.future);

      state = state.copyWith(status: KpltFormStatus.initial);
      return true;

    } catch (e) {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateForm({required FormKPLT originalKplt}) async {
    state = state.copyWith(status: KpltFormStatus.loading);
    try {
      final Map<String, dynamic> dataToUpdate = {
        'nama_kplt': state.namaLokasi,
        'alamat': state.alamat,
        'provinsi': state.provinsi,
        'kabupaten': state.kabupaten,
        'kecamatan': state.kecamatan,
        'desa_kelurahan': state.desaKelurahan,
        'latitude': state.latLng?.latitude,
        'longitude': state.latLng?.longitude,
        'format_store': state.formatStore,
        'bentuk_objek': state.bentukObjek,
        'alas_hak': state.alasHak,
        'jumlah_lantai': state.jumlahLantai,
        'lebar_depan': state.lebarDepan,
        'panjang': state.panjang,
        'luas': state.luas,
        'harga_sewa': state.hargaSewa,
        'nama_pemilik': state.namaPemilik,
        'kontak_pemilik': state.kontakPemilik,
        'karakter_lokasi': state.karakterLokasi,
        'sosial_ekonomi': state.sosialEkonomi,
        'pe_status': state.peStatus,
        'skor_fpl': state.skorFpl,
        'std': state.std,
        'apc': state.apc,
        'spd': state.spd,
        'pe_rab': state.peRab,
        'pdf_foto': state.pdfFoto,
        'counting_kompetitor': state.countingKompetitor,
        'pdf_pembanding': state.pdfPembanding,
        'pdf_kks': state.pdfKks,
        'excel_fpl': state.excelFpl,
        'excel_pe': state.excelPe,
        'pdf_form_ukur': state.pdfFormUkur,
        'video_traffic_siang': state.videoTrafficSiang,
        'video_traffic_malam': state.videoTrafficMalam,
        'video_360_siang': state.video360Siang,
        'video_360_malam': state.video360Malam,
        'peta_coverage': state.petaCoverage,
      };

      // Hapus data yang nilainya null agar tidak menimpa data yang sudah ada di DB dengan null
      dataToUpdate.removeWhere((key, value) => value == null);

      if (dataToUpdate.isEmpty) {
        state = state.copyWith(status: KpltFormStatus.initial);
        return true; 
      }

      await _repository.updateKplt(originalKplt.id, dataToUpdate, originalKplt: originalKplt);

      _ref.invalidate(kpltInProgressProvider);
      _ref.invalidate(kpltHistoryProvider);
      _ref.invalidate(kpltDetailProvider(originalKplt.id));

      state = state.copyWith(status: KpltFormStatus.initial);
      return true;
    } catch (e) {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: e.toString());
      return false;
    }
  }
}

final kpltFormProvider = StateNotifierProvider.autoDispose
    .family<KpltFormNotifier, KpltFormState, String>((ref, ulokId) {
  final repository = ref.watch(kpltRepositoryProvider);
  final draftManager = ref.watch(kpltDraftManagerProvider);
  return KpltFormNotifier(repository, draftManager, ref, ulokId: ulokId, initialData: null);
});

final kpltEditFormProvider = StateNotifierProvider.autoDispose
    .family<KpltFormNotifier, KpltFormState, FormKPLT>((ref, initialData) {
  final repository = ref.watch(kpltRepositoryProvider);
  final draftManager = ref.watch(kpltDraftManagerProvider);
  return KpltFormNotifier(
    repository,
    draftManager,
    ref, // Berikan 'ref'
    ulokId: initialData.ulokId,
    initialData: initialData,
  );
});