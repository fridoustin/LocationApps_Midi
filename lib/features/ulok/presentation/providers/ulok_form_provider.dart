import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_local_datasource.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_remote_datasource.dart';
import 'package:midi_location/features/ulok/data/repositories/ulok_form_repository_impl.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_form_repository.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';

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

final formatStoreOptionsProvider = FutureProvider<List<String>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase.rpc(
      'get_enum_labels',
      params: {'enum_type_name': 'format_store'},
    );
    return (response as List).map((item) => item.toString()).toList();
  } catch (e) {
    debugPrint("Error fetching format_store: $e");
    rethrow;
  }
});

final bentukObjekOptionsProvider = FutureProvider<List<String>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase.rpc(
      'get_enum_labels',
      params: {'enum_type_name': 'bentuk_objek'},
    );
    return (response as List).map((item) => item.toString()).toList();
  } catch (e) {
    debugPrint("Error fetching bentuk_objek: $e");
    rethrow;
  }
});


// --- State & Notifier untuk Form Tambah ULOK ---
enum FormAction { none, savingDraft, submitting }

@immutable
class UlokFormState {
  final FormAction action; // Ganti isLoading dengan ini
  final String? successMessage;
  final String? errorMessage;

  const UlokFormState({
    this.action = FormAction.none, // Nilai default
    this.successMessage,
    this.errorMessage
  });

  UlokFormState copyWith({
    FormAction? action,
    String? successMessage,
    String? errorMessage
  }) {
    return UlokFormState(
      action: action ?? this.action,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

class UlokFormNotifier extends StateNotifier<UlokFormState> {
  final UlokFormRepository _repository;
  final Ref _ref;

  UlokFormNotifier(this._repository, this._ref) : super(const UlokFormState());

  Future<bool> saveDraft(UlokFormData data) async {
    // Set state ke savingDraft
    state = state.copyWith(action: FormAction.savingDraft, errorMessage: null, successMessage: null);
    try {
      await _repository.saveDraft(data);
      // Kembalikan state ke none
      state = state.copyWith(action: FormAction.none, successMessage: "ULOK berhasil disimpan sebagai draft.");
      _ref.invalidate(ulokDraftsProvider);
      return true;
    } catch (e) {
      // Kembalikan state ke none
      state = state.copyWith(action: FormAction.none, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> submitForm(UlokFormData data) async {
    state = state.copyWith(action: FormAction.submitting, errorMessage: null, successMessage: null);
    
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
        await saveDraft(data);
        state = state.copyWith(action: FormAction.none, successMessage: "Tidak ada koneksi. Data disimpan di Draft.");
        return false;
    }

    try {
      final profile = await _ref.read(profileDataProvider.future);
      await _repository.submitUlok(data, profile.branchId);
      
      // Jika submit berhasil, hapus draft dari local storage menggunakan localId
      await _repository.deleteDraft(data.localId); 
      
      state = state.copyWith(action: FormAction.none);
      _ref.invalidate(ulokDraftsProvider);
      return true;
    } catch (e) {
      await saveDraft(data);
      state = state.copyWith(action: FormAction.none, errorMessage: "Gagal submit. Disimpan ke Draft. Error: ${e.toString()}");
      return false;
    }
  }
}

final ulokFormProvider =
    StateNotifierProvider<UlokFormNotifier, UlokFormState>((ref) {
  return UlokFormNotifier(ref.watch(ulokFormRepositoryProvider), ref);
});

final ulokDraftsProvider = FutureProvider.autoDispose<List<UlokFormData>>((ref) async {
  final repository = ref.watch(ulokFormRepositoryProvider);
  final searchQuery = ref.watch(ulokSearchQueryProvider); // Pantau search query

  // Ambil semua draft dari local storage
  final allDrafts = await repository.getDrafts();

  // Jika tidak ada query pencarian, kembalikan semua draft
  if (searchQuery.isEmpty) {
    return allDrafts;
  }

  // Jika ada query, filter draft berdasarkan nama atau alamat
  final filteredDrafts = allDrafts.where((draft) {
    final queryLower = searchQuery.toLowerCase();
    final nameLower = draft.namaUlok.toLowerCase();
    final addressLower = draft.alamat.toLowerCase();

    return nameLower.contains(queryLower) || addressLower.contains(queryLower);
  }).toList();

  return filteredDrafts;
});

// --- State & Notifier untuk Form Edit ULOK ---
@immutable
class UlokEditState {
  final bool isLoading;
  final String? errorMessage;
  const UlokEditState({this.isLoading = false, this.errorMessage});

  UlokEditState copyWith({bool? isLoading, String? errorMessage}) {
    return UlokEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UlokEditNotifier extends StateNotifier<UlokEditState> {
  final UlokFormRepository _repository;
  UlokEditNotifier(this._repository) : super(const UlokEditState());

  Future<bool> updateUlok(String ulokId, UlokFormData data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateUlok(ulokId, data);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final ulokEditProvider =
    StateNotifierProvider<UlokEditNotifier, UlokEditState>((ref) {
  return UlokEditNotifier(ref.watch(ulokFormRepositoryProvider));
});

