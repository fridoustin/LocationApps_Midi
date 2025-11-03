import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/lokasi/data/datasources/kplt_progress_remote_datasource.dart';
import 'package:midi_location/features/lokasi/data/repositories/kplt_progress_repository_impl.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/domain/repositories/kplt_progress_repository.dart';

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

// Provider untuk fetch all progress list (by current user) dengan enrichment
final progressListProvider = FutureProvider.autoDispose<List<ProgressKplt>>((ref) async {
  final repo = ref.watch(kpltProgressRepositoryProvider);
  final progressList = await repo.getAllProgress();
  
  // Enrich each progress dengan percentage dan status yang benar
  final enrichedList = <ProgressKplt>[];
  
  for (var progress in progressList) {
    final completionData = await repo.getCompletionStatus(progress.id);
    
    // Calculate percentage
    final percentage = ProgressCalculator.calculatePercentage(completionData);
    
    // Determine current status
    final currentStatusString = ProgressCalculator.determineCurrentStatus(completionData);
    final currentStatus = ProgressKpltStatus.fromString(currentStatusString);
    
    // Update progress dengan data yang benar
    enrichedList.add(
      progress.copyWith(
        computedPercentage: percentage,
        status: currentStatus,
      ),
    );
  }
  
  return enrichedList;
});

// Provider untuk fetch progress by KPLT ID dengan enrichment
final progressByKpltIdProvider = FutureProvider.family.autoDispose<ProgressKplt?, String>(
  (ref, kpltId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    final progress = await repo.getProgressByKpltId(kpltId);
    
    if (progress == null) return null;
    
    // Enrich dengan completion data
    final completionData = await repo.getCompletionStatus(progress.id);
    final percentage = ProgressCalculator.calculatePercentage(completionData);
    final currentStatusString = ProgressCalculator.determineCurrentStatus(completionData);
    final currentStatus = ProgressKpltStatus.fromString(currentStatusString);
    
    return progress.copyWith(
      computedPercentage: percentage,
      status: currentStatus,
    );
  },
);

// Provider untuk get completion status (return Map<String, dynamic>)
final completionStatusProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>(
  (ref, progressId) async {
    final repo = ref.watch(kpltProgressRepositoryProvider);
    return await repo.getCompletionStatus(progressId);
  },
);