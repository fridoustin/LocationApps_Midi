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

// 2. Enum untuk melacak tab yang aktif
enum KpltTab { recent, history }

// 3. Provider untuk daftar data ULok, akan mengambil data berdasarkan tab yang aktif
final kpltListProvider = FutureProvider<List<FormKPLT>>((ref) async {
  final repository = ref.watch(kpltRepositoryProvider);
  final activeTab = ref.watch(kpltTabProvider);

  final searchQuery = ref.watch(kpltSearchQueryProvider);

  if (activeTab == KpltTab.recent) {
    return repository.getRecentKplt(searchQuery);
  } else {
    return repository.getHistoryKplt(searchQuery);
  }
});

// 4. Provider untuk mengelola state tab yang sedang aktif
final kpltTabProvider = StateProvider<KpltTab>((ref) => KpltTab.recent);