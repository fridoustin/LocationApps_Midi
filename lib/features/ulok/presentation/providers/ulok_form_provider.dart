// ignore_for_file: unused_result

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
      : _ulokIdToEdit = initialState?.ulokId,
        super(initialState ?? UlokFormState(localId: const Uuid().v4(), status: UlokFormStatus.initial));

  void _updateWithTimestamp(UlokFormState Function() updateFn) {
    state = updateFn().copyWith(lastEdited: DateTime.now());
  }

  // Methods untuk meng-update setiap field dari UI
  void onNamaUlokChanged(String value) => _updateWithTimestamp(() => state.copyWith(namaUlok: value));
  void onAlamatChanged(String value) => _updateWithTimestamp(() => state.copyWith(alamat: value));
  void onLatLngChanged(LatLng value) => _updateWithTimestamp(() => state.copyWith(latLng: value));
  
  void onProvinceSelected(WilayahEntity? province) {
    _updateWithTimestamp(() => state.copyWith(
      provinsi: province?.name,
      kabupaten: null,
      kecamatan: null,
      desa: null,
    ));
    // Update provider wilayah
    _ref.read(selectedProvinceProvider.notifier).state = province;
    _ref.invalidate(regenciesProvider);
  }

  void onRegencySelected(WilayahEntity? regency) {
    _updateWithTimestamp(() => state.copyWith(
      kabupaten: regency?.name,
      kecamatan: null,
      desa: null,
    ));
    _ref.read(selectedRegencyProvider.notifier).state = regency;
    _ref.invalidate(districtsProvider);
  }

  void onDistrictSelected(WilayahEntity? district) {
    _updateWithTimestamp(() => state.copyWith(
      kecamatan: district?.name,
      desa: null,
    ));
    _ref.read(selectedDistrictProvider.notifier).state = district;
    _ref.invalidate(villagesProvider);
  }

  void onVillageSelected(WilayahEntity? village) {
    _updateWithTimestamp(() => state.copyWith(desa: village?.name));
    _ref.read(selectedVillageProvider.notifier).state = village;
  }
  
  void onFormatStoreChanged(String value) => _updateWithTimestamp(() => state.copyWith(formatStore: value));
  void onBentukObjekChanged(String value) => _updateWithTimestamp(() => state.copyWith(bentukObjek: value));
  void onAlasHakChanged(String value) => _updateWithTimestamp(() => state.copyWith(alasHak: value));
  void onNamaPemilikChanged(String value) => _updateWithTimestamp(() => state.copyWith(namaPemilik: value));
  void onKontakPemilikChanged(String value) => _updateWithTimestamp(() => state.copyWith(kontakPemilik: value));
  void onJumlahLantaiChanged(String value) => _updateWithTimestamp(() => state.copyWith(jumlahLantai: int.tryParse(value)));
  void onLebarDepanChanged(String value) => _updateWithTimestamp(() => state.copyWith(lebarDepan: double.tryParse(value)));
  void onPanjangChanged(String value) => _updateWithTimestamp(() => state.copyWith(panjang: double.tryParse(value)));
  void onLuasChanged(String value) => _updateWithTimestamp(() => state.copyWith(luas: double.tryParse(value)));
  void onHargaSewaChanged(String value) => _updateWithTimestamp(() => state.copyWith(hargaSewa: double.tryParse(value)));
  void onFilePicked(File? file) => _updateWithTimestamp(() => state.copyWith(formUlokPdf: file));

  Future<bool> saveDraft() async {
    try {
      final draftToSave = state.copyWith(lastEdited: DateTime.now());
      state = draftToSave;
      
      await _repository.saveDraft(draftToSave);
      _ref.invalidate(ulokDraftsProvider);
      return true;
    } catch (e) {
      debugPrint("Error saving draft: $e");
      return false;
    }
  }

  Future<void> submitOrUpdateForm() async {
    final s = state;
    bool isFormValid = true;
    if (s.namaUlok == null || s.namaUlok!.isEmpty || s.latLng == null || 
        s.provinsi == null || s.kabupaten == null || s.kecamatan == null || 
        s.desa == null || s.alamat == null || s.formatStore == null || 
        s.bentukObjek == null || s.alasHak == null || s.jumlahLantai == null || 
        s.lebarDepan == null || s.panjang == null || s.luas == null || 
        s.hargaSewa == null || s.namaPemilik == null || s.kontakPemilik == null) {
      isFormValid = false;
    }

    final bool isFileMissing;
    if (_ulokIdToEdit != null) { 
      isFileMissing = s.formUlokPdf == null && (s.existingFormUlokUrl == null || s.existingFormUlokUrl!.isEmpty);
    } else { 
      isFileMissing = s.formUlokPdf == null;
    }
    
    if (isFileMissing) {
      isFormValid = false;
    }
    
    if (!isFormValid) {
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
        localId: state.localId,
        namaUlok: state.namaUlok!,
        latLng: state.latLng!,
        provinsi: state.provinsi!,
        kabupaten: state.kabupaten!,
        kecamatan: state.kecamatan!,
        desa: state.desa!,
        alamat: state.alamat!,
        formatStore: state.formatStore!,
        bentukObjek: state.bentukObjek!,
        alasHak: state.alasHak!,
        jumlahLantai: state.jumlahLantai!,
        lebarDepan: state.lebarDepan!,
        panjang: state.panjang!,
        luas: state.luas!,
        hargaSewa: state.hargaSewa!,
        namaPemilik: state.namaPemilik!,
        kontakPemilik: state.kontakPemilik!,
        formUlokPdf: state.formUlokPdf,
        existingFormUlokUrl: state.existingFormUlokUrl,
      );

      if (_ulokIdToEdit == null) {
        await _repository.submitUlok(formData, profile.branchId);
        await _repository.deleteDraft(state.localId); 
      } else {
        await _repository.updateUlok(_ulokIdToEdit, formData);
      }

      await _ref.refresh(ulokDraftsProvider.future);
      await _ref.refresh(ulokListProvider.future);
      
      state = state.copyWith(status: UlokFormStatus.success);

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