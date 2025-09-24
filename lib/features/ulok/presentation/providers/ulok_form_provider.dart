import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_local_datasource.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_remote_datasource.dart';
import 'package:midi_location/features/ulok/data/repositories/ulok_form_repository_impl.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_form_repository.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/presentation/providers/wilayah_provider.dart';
import 'package:uuid/uuid.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((event) => event.first);
});

// --- Providers untuk Data Layer ---
final ulokFormLocalDataSourceProvider = Provider<UlokFormLocalDataSource>((ref) {
  return UlokFormLocalDataSource();
});

final ulokFormDataSourceProvider = Provider<UlokFormRemoteDataSource>((ref) {
  return UlokFormRemoteDataSource(ref.watch(supabaseClientProvider));
});

final ulokFormRepositoryProvider = Provider<UlokFormRepository>((ref) {
  return UlokFormRepositoryImpl(
    ref.watch(ulokFormDataSourceProvider),
    ref.watch(ulokFormLocalDataSourceProvider),
  );
});

final ulokDropdownOptionsProvider = FutureProvider.family<List<String>, String>((ref, enumName) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase.rpc('get_enum_labels', params: {'enum_type_name': enumName});
    return (response as List).map((item) => item.toString()).toList();
  } catch (e) {
    debugPrint("Error fetching enum '$enumName': $e");
    rethrow;
  }
});

class UlokFormNotifier extends StateNotifier<UlokFormState> {
  final UlokFormRepository _repository;
  final Ref _ref;
  final String? _ulokIdToEdit;

  UlokFormNotifier(this._repository, this._ref, UlokFormState? initialState)
      : _ulokIdToEdit = initialState?.localId,
        super(initialState ?? UlokFormState(localId: const Uuid().v4(), status: UlokFormStatus.initial));

  // Methods untuk meng-update setiap field dari UI
  void onNamaUlokChanged(String value) => state = state.copyWith(namaUlok: value);
  void onAlamatChanged(String value) => state = state.copyWith(alamat: value);
  void onLatLngChanged(LatLng value) => state = state.copyWith(latLng: value);
  void onProvinceSelected(WilayahEntity? province) {
    state = state.copyWith(
      provinsi: province?.name,
      kabupaten: null,
      kecamatan: null,
      desa: null,
    );
    // Update provider wilayah
    _ref.read(selectedProvinceProvider.notifier).state = province;
    _ref.invalidate(regenciesProvider);
  }

  void onRegencySelected(WilayahEntity? regency) {
    state = state.copyWith(
      kabupaten: regency?.name,
      kecamatan: null,
      desa: null,
    );
    _ref.read(selectedRegencyProvider.notifier).state = regency;
    _ref.invalidate(districtsProvider);
  }

  void onDistrictSelected(WilayahEntity? district) {
    state = state.copyWith(
      kecamatan: district?.name,
      desa: null,
    );
    _ref.read(selectedDistrictProvider.notifier).state = district;
    _ref.invalidate(villagesProvider);
  }

  void onVillageSelected(WilayahEntity? village) {
    state = state.copyWith(desa: village?.name);
    _ref.read(selectedVillageProvider.notifier).state = village;
  }
  void onFormatStoreChanged(String value) => state = state.copyWith(formatStore: value);
  void onBentukObjekChanged(String value) => state = state.copyWith(bentukObjek: value);
  void onAlasHakChanged(String value) => state = state.copyWith(alasHak: value);
  void onNamaPemilikChanged(String value) => state = state.copyWith(namaPemilik: value);
  void onKontakPemilikChanged(String value) => state = state.copyWith(kontakPemilik: value);
  void onJumlahLantaiChanged(String value) => state = state.copyWith(jumlahLantai: int.tryParse(value));
  void onLebarDepanChanged(String value) => state = state.copyWith(lebarDepan: double.tryParse(value));
  void onPanjangChanged(String value) => state = state.copyWith(panjang: double.tryParse(value));
  void onLuasChanged(String value) => state = state.copyWith(luas: double.tryParse(value));
  void onHargaSewaChanged(String value) => state = state.copyWith(hargaSewa: double.tryParse(value));
  void onFilePicked(File? file) => state = state.copyWith(formUlokPdf: file);

  Future<bool> saveDraft() async {
    try {
      await _repository.saveDraft(state);
      _ref.invalidate(ulokDraftsProvider);
      return true;
    } catch (e) {
      debugPrint("Error saving draft: $e");
      return false;
    }
  }

  Future<void> submitOrUpdateForm() async {
    final s = state;
    if (s.namaUlok == null || s.namaUlok!.isEmpty || s.latLng == null || 
        s.provinsi == null || s.kabupaten == null || s.kecamatan == null || 
        s.desa == null || s.alamat == null || s.formatStore == null || 
        s.bentukObjek == null || s.alasHak == null || s.jumlahLantai == null || 
        s.lebarDepan == null || s.panjang == null || s.luas == null || 
        s.hargaSewa == null || s.namaPemilik == null || s.kontakPemilik == null ||
        s.formUlokPdf == null) {
      state = state.copyWith(status: UlokFormStatus.error, errorMessage: "Harap lengkapi semua data wajib.");
      await Future.delayed(const Duration(milliseconds: 100)); 
      state = state.copyWith(status: UlokFormStatus.initial, errorMessage: null);
      return;
    }

    state = state.copyWith(status: UlokFormStatus.loading);

    try {
      final profile = await _ref.read(userProfileProvider.future);
      if (profile == null) throw Exception("Profil user tidak ditemukan.");

      final formData = UlokFormData(
        localId: s.localId!,
        namaUlok: s.namaUlok!,
        latLng: s.latLng!,
        provinsi: s.provinsi!,
        kabupaten: s.kabupaten!,
        kecamatan: s.kecamatan!,
        desa: s.desa!,
        alamat: s.alamat!,
        formatStore: s.formatStore!,
        bentukObjek: s.bentukObjek!,
        alasHak: s.alasHak!,
        jumlahLantai: s.jumlahLantai!,
        lebarDepan: s.lebarDepan!,
        panjang: s.panjang!,
        luas: s.luas!,
        hargaSewa: s.hargaSewa!,
        namaPemilik: s.namaPemilik!,
        kontakPemilik: s.kontakPemilik!,
        formUlokPdf: s.formUlokPdf!,
      );

      if (_ulokIdToEdit == null) {
        await _repository.submitUlok(formData, profile.branchId);
        await _repository.deleteDraft(s.localId!); 
      } else {
        await _repository.updateUlok(_ulokIdToEdit, formData);
      }
      
      state = state.copyWith(status: UlokFormStatus.success);
      _ref.invalidate(ulokDraftsProvider);
      _ref.invalidate(ulokListProvider);

    } catch (e) {
      state = state.copyWith(status: UlokFormStatus.error, errorMessage: e.toString());
    }
  }
}

// Provider utama untuk form (bisa untuk create atau edit)
final ulokFormProvider = StateNotifierProvider.autoDispose
    .family<UlokFormNotifier, UlokFormState, UlokFormState?>((ref, initialState) {
  final repository = ref.watch(ulokFormRepositoryProvider);
  return UlokFormNotifier(repository, ref, initialState);
});

// Provider untuk memuat daftar draft dari local storage
final ulokDraftsProvider = FutureProvider.autoDispose<List<UlokFormState>>((ref) async {
  final repository = ref.watch(ulokFormRepositoryProvider);
  return repository.getDrafts();
});

