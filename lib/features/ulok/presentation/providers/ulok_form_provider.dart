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
    // INI AKAN MENCETAK ERROR ASLI DARI SUPABASE
    debugPrint("Error fetching format_store: $e");
    // Lempar kembali error agar .when() bisa menanganinya
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
    // INI AKAN MENCETAK ERROR ASLI DARI SUPABASE
    debugPrint("Error fetching bentuk_objek: $e");
    rethrow;
  }
});

// --- State & Notifier untuk Presentation Layer ---
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
  final Ref _ref; // Butuh ref untuk membaca provider lain

  UlokFormNotifier(this._repository, this._ref) : super(const UlokFormState());

  Future<bool> submitForm(UlokFormData data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Ambil branch_id dari profil pengguna
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
