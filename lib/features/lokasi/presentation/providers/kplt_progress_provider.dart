import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/lokasi/data/datasources/kplt_progress_remote_datasource.dart';
import 'package:midi_location/features/lokasi/data/repositories/kplt_progress_repository_impl.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
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