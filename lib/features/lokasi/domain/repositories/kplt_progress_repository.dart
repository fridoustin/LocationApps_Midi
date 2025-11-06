import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';

abstract class KpltProgressRepository {
  Future<List<ProgressKplt>> getRecentProgress(String query, {KpltFilter? filter});
  Future<List<ProgressKplt>> getHistoryProgress(String query, {KpltFilter? filter});
  Future<ProgressKplt?> getProgressByKpltId(String kpltId);
  Future<String> createProgress(String kpltId);
  Future<void> updateStatus(String progressId, String status);
  Future<Map<String, dynamic>> getCompletionStatus(String progressId);
  Future<Mou?> getMouData(String progressKpltId);
}

