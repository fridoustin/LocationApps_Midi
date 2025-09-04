import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_remote_datasource.dart';
import 'package:midi_location/features/ulok/data/repositories/ulok_form_repository_impl.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_form_repository.dart';
// --- Providers untuk Data Layer ---
final ulokFormDataSourceProvider = Provider<UlokFormRemoteDataSource>((ref) {
  return UlokFormRemoteDataSource(ref.watch(supabaseClientProvider));
});

final ulokFormRepositoryProvider = Provider<UlokFormRepository>((ref) {
  return UlokFormRepositoryImpl(ref.watch(ulokFormDataSourceProvider));
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
@immutable
class UlokFormState {
  final bool isLoading;
  final String? errorMessage;
  const UlokFormState({this.isLoading = false, this.errorMessage});

  UlokFormState copyWith({bool? isLoading, String? errorMessage}) {
    return UlokFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UlokFormNotifier extends StateNotifier<UlokFormState> {
  final UlokFormRepository _repository;
  final Ref _ref;

  UlokFormNotifier(this._repository, this._ref) : super(const UlokFormState());

  Future<bool> submitForm(UlokFormData data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _ref.read(profileDataProvider.future);
      await _repository.submitUlok(data, profile.branchId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final ulokFormProvider =
    StateNotifierProvider<UlokFormNotifier, UlokFormState>((ref) {
  return UlokFormNotifier(ref.watch(ulokFormRepositoryProvider), ref);
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

