import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_remote_datasource.dart';
import 'package:midi_location/features/ulok/data/repositories/ulok_repository_impl.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_repository.dart';

// 1. Sediakan instance dari DataSource dan Repository
final ulokRemoteDataSourceProvider = Provider<UlokRemoteDataSource>((ref) {
  return UlokRemoteDataSource(ref.watch(supabaseClientProvider));
});

final ulokRepositoryProvider = Provider<UlokRepository>((ref) {
  return UlokRepositoryImpl(ref.watch(ulokRemoteDataSourceProvider));
});

final ulokSearchQueryProvider = StateProvider<String>((ref) => '');

// 2. Enum untuk melacak tab yang aktif
enum UlokTab { recent, history }

// 3. Provider untuk daftar data ULok, akan mengambil data berdasarkan tab yang aktif
final ulokListProvider = FutureProvider<List<UsulanLokasi>>((ref) async {
  final repository = ref.watch(ulokRepositoryProvider);
  final activeTab = ref.watch(ulokTabProvider);

  final searchQuery = ref.watch(ulokSearchQueryProvider);

  if (activeTab == UlokTab.recent) {
    return repository.getRecentUlok(searchQuery);
  } else {
    return repository.getHistoryUlok(searchQuery);
  }
});

// 4. Provider untuk mengelola state tab yang sedang aktif
final ulokTabProvider = StateProvider<UlokTab>((ref) => UlokTab.recent);
final showDraftsProvider = StateProvider<bool>((ref) => false);