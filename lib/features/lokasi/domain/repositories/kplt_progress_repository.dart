import 'package:midi_location/features/lokasi/domain/entities/grand_opening.dart';
import 'package:midi_location/features/lokasi/domain/entities/izin_tetangga.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/domain/entities/notaris.dart';
import 'package:midi_location/features/lokasi/domain/entities/perizinan.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/domain/entities/renovasi.dart';

abstract class KpltProgressRepository {
  Future<List<ProgressKplt>> getRecentProgress(String query, {KpltFilter? filter});
  Future<List<ProgressKplt>> getHistoryProgress(String query, {KpltFilter? filter});
  Future<ProgressKplt?> getProgressByKpltId(String kpltId);
  Future<String> createProgress(String kpltId);
  Future<void> updateStatus(String progressId, String status);
  Future<Map<String, dynamic>> getCompletionStatus(String progressId);
  Future<Mou?> getMouData(String progressKpltId);
  Future<IzinTetangga?> getIzinTetanggaData(String progressKpltId);
  Future<Perizinan?> getPerizinanData(String progressKpltId);
  Future<List<HistoryPerizinan>> getHistoryPerizinan(String perizinanId);
  Future<Notaris?> getNotarisData(String progressKpltId);
  Future<List<HistoryNotaris>> getHistoryNotaris(String notarisId);
  Future<Renovasi?> getRenovasiData(String progressKpltId);
  Future<List<HistoryRenovasi>> getHistoryRenovasi(String renovasiId);
  Future<GrandOpening?> getGrandOpeningData(String progressKpltId);
}

