import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';

abstract class KpltProgressRepository {
  Future<List<ProgressKplt>> getAllProgress();
  Future<ProgressKplt?> getProgressByKpltId(String kpltId);
  Future<String> createProgress(String kpltId);
  Future<void> updateStatus(String progressId, String status);
  Future<Map<String, dynamic>> getCompletionStatus(String progressId);
}