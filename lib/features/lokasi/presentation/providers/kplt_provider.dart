// 1. Sediakan instance dari DataSource dan Repository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/lokasi/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/lokasi/data/repositories/kplt_repository_impl.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/domain/repositories/kplt_repository.dart';

final kpltRemoteDataSourceProvider = Provider<KpltRemoteDatasource>((ref) {
  return KpltRemoteDatasource(ref.watch(supabaseClientProvider));
});

final kpltRepositoryProvider = Provider<KpltRepository>((ref) {
  return KpltRepositoryImpl(ref.watch(kpltRemoteDataSourceProvider));
});

final kpltSearchQueryProvider = StateProvider<String>((ref) => '');
final kpltFilterProvider = StateProvider<KpltFilter>((ref) => KpltFilter.empty);

final kpltNeedInputProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  final filter = ref.watch(kpltFilterProvider);
  // Memanggil metode yang sesuai dari repository dengan filter
  return repository.getKpltNeedInput(searchQuery, filter: filter);
});

// Provider untuk seksi "Sedang Proses" di tab Recent
final kpltInProgressProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  final filter = ref.watch(kpltFilterProvider);
  // Memanggil metode yang sesuai dari repository dengan filter
  return repository.getRecentKplt(searchQuery, filter: filter);
});

// Provider untuk data di tab History
final kpltHistoryProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  final filter = ref.watch(kpltFilterProvider);
  // Memanggil metode yang sesuai dari repository dengan filter
  return repository.getHistoryKplt(searchQuery, filter: filter);
});

final dropdownOptionsProvider = FutureProvider.family<List<String>, String>((ref, enumName) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .rpc('get_enum_labels', params: {'enum_type_name': enumName});
  
  return (response as List).map((item) => item.toString()).toList();
});

final kpltDetailProvider = 
    FutureProvider.family<FormKPLT, String>((ref, kpltId) {
  final repository = ref.watch(kpltRepositoryProvider); 
  return repository.getKpltById(kpltId);
});