// 1. Sediakan instance dari DataSource dan Repository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/data/repositories/kplt_repository_impl.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';

final kpltRemoteDataSourceProvider = Provider<KpltRemoteDatasource>((ref) {
  return KpltRemoteDatasource(ref.watch(supabaseClientProvider));
});

final kpltRepositoryProvider = Provider<KpltRepository>((ref) {
  return KpltRepositoryImpl(ref.watch(kpltRemoteDataSourceProvider));
});

final kpltSearchQueryProvider = StateProvider<String>((ref) => '');

final kpltNeedInputProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  // Memanggil metode yang sesuai dari repository
  return repository.getKpltNeedInput(searchQuery);
});

// Provider untuk seksi "Sedang Proses" di tab Recent
final kpltInProgressProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  // Memanggil metode yang sesuai dari repository
  return repository.getRecentKplt(searchQuery);
});

// Provider untuk data di tab History
final kpltHistoryProvider = FutureProvider.autoDispose<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final searchQuery = ref.watch(kpltSearchQueryProvider);
  // Memanggil metode yang sesuai dari repository
  return repository.getHistoryKplt(searchQuery);
});