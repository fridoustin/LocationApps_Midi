import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/lokasi/data/datasources/kplt_progress_remote_datasource.dart';
import 'package:midi_location/features/lokasi/data/repositories/kplt_progress_repository_impl.dart';
import 'package:midi_location/features/lokasi/domain/entities/izin_tetangga.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/domain/entities/notaris.dart';
import 'package:midi_location/features/lokasi/domain/entities/perizinan.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/domain/entities/renovasi.dart';
import 'package:midi_location/features/lokasi/domain/repositories/kplt_progress_repository.dart';
import 'package:midi_location/features/lokasi/presentation/views/progress_kplt_view.dart';

// Provider untuk data source
final kpltProgressRemoteDatasourceProvider = Provider<KpltProgressRemoteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return KpltProgressRemoteDatasource(client);
});

// Provider untuk repository
final kpltProgressRepositoryProvider = Provider<KpltProgressRepository>((ref) {
  final ds = ref.watch(kpltProgressRemoteDatasourceProvider);
  return KpltProgressRepositoryImpl(ds);
});

Future<ProgressKplt> _enrichProgress(KpltProgressRepository repo, ProgressKplt progress) async {
  final completionData = await repo.getCompletionStatus(progress.id);
  final percentage = ProgressCalculator.calculatePercentage(completionData);
  final currentStatusString = ProgressCalculator.determineCurrentStatus(completionData);
  final currentStatus = ProgressKpltStatus.fromString(currentStatusString);
  
  return progress.copyWith(
    computedPercentage: percentage,
    status: currentStatus,
  );
}

final recentProgressListProvider = FutureProvider.autoDispose<List<ProgressKplt>>((ref) async {
  final repo = ref.watch(kpltProgressRepositoryProvider);
  final query = ref.watch(progressSearchQueryProvider);
  final filter = ref.watch(progressFilterProvider);
  final progressList = await repo.getRecentProgress(query, filter: filter);
  final enrichedList = await Future.wait(
    progressList.map((progress) => _enrichProgress(repo, progress))
  );
  
  return enrichedList;
});

final historyProgressListProvider = FutureProvider.autoDispose<List<ProgressKplt>>((ref) async {
  final repo = ref.watch(kpltProgressRepositoryProvider);
  final query = ref.watch(progressSearchQueryProvider);
  final filter = ref.watch(progressFilterProvider);
  final progressList = await repo.getHistoryProgress(query, filter: filter);
  final enrichedList = await Future.wait(
    progressList.map((progress) => _enrichProgress(repo, progress))
  );
  
  return enrichedList;
});

final progressByKpltIdProvider = FutureProvider.family.autoDispose<ProgressKplt?, String>(
  (ref, kpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    final progress = await repo.getProgressByKpltId(kpltId);
    
    if (progress == null) return null;
    
    // Enrich dengan completion data
    final repoForEnrich = ref.watch(kpltProgressRepositoryProvider);
    return await _enrichProgress(repoForEnrich, progress);
  },
);

final completionStatusProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>(
  (ref, progressId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getCompletionStatus(progressId);
  },
);

/// Provider untuk mendapatkan data MOU berdasarkan progress_kplt_id
final mouDataProvider = FutureProvider.family.autoDispose<Mou?, String>(
  (ref, progressKpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getMouData(progressKpltId);
  },
);

/// Provider untuk mendapatkan data Izin Tetangga berdasarkan progress_kplt_id
final izinTetanggaDataProvider = FutureProvider.family.autoDispose<IzinTetangga?, String>(
  (ref, progressKpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getIzinTetanggaData(progressKpltId);
  },
);

/// Provider untuk mendapatkan data Perizinan berdasarkan progress_kplt_id
final perizinanDataProvider = FutureProvider.family.autoDispose<Perizinan?, String>(
  (ref, progressKpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getPerizinanData(progressKpltId);
  },
);

/// Provider untuk mendapatkan history perizinan berdasarkan perizinan_id
final historyPerizinanProvider = FutureProvider.family.autoDispose<List<HistoryPerizinan>, String>(
  (ref, perizinanId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getHistoryPerizinan(perizinanId);
  },
);

/// Provider untuk mendapatkan data Notaris berdasarkan progress_kplt_id
final notarisDataProvider = FutureProvider.family.autoDispose<Notaris?, String>(
  (ref, progressKpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getNotarisData(progressKpltId);
  },
);

/// Provider untuk mendapatkan history notaris berdasarkan notaris_id
final historyNotarisProvider = FutureProvider.family.autoDispose<List<HistoryNotaris>, String>(
  (ref, notarisId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getHistoryNotaris(notarisId);
  },
);

final renovasiDataProvider = FutureProvider.family.autoDispose<Renovasi?, String>(
  (ref, progressKpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getRenovasiData(progressKpltId);
  },
);

/// Provider untuk mendapatkan history renovasi berdasarkan renovasi_id
final historyRenovasiProvider = FutureProvider.family.autoDispose<List<HistoryRenovasi>, String>(
  (ref, renovasiId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getHistoryRenovasi(renovasiId);
  },
);