import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/data/datasources/kplt_progress_remote_datasource.dart';
import 'package:midi_location/features/lokasi/domain/entities/mou.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/domain/repositories/kplt_progress_repository.dart';

class KpltProgressRepositoryImpl implements KpltProgressRepository {
  final KpltProgressRemoteDatasource remoteDataSource;

  KpltProgressRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProgressKplt>> getRecentProgress(String query, {KpltFilter? filter}) async {
    final raw = await remoteDataSource.getRecentProgress(query, filter: filter);
    return raw.map((e) => ProgressKplt.fromMap(e)).toList();
  }

  @override
  Future<List<ProgressKplt>> getHistoryProgress(String query, {KpltFilter? filter}) async {
    final raw = await remoteDataSource.getHistoryProgress(query, filter: filter);
    return raw.map((e) => ProgressKplt.fromMap(e)).toList();
  }

  @override
  Future<ProgressKplt?> getProgressByKpltId(String kpltId) async {
    final raw = await remoteDataSource.getProgressByKpltId(kpltId);
    if (raw == null) return null;
    return ProgressKplt.fromMap(raw);
  }

  @override
  Future<String> createProgress(String kpltId) async {
    return await remoteDataSource.createProgress(kpltId);
  }

  @override
  Future<void> updateStatus(String progressId, String status) async {
    await remoteDataSource.updateStatus(progressId, status);
  }

  @override
  Future<Map<String, dynamic>> getCompletionStatus(String progressId) async {
    return await remoteDataSource.getCompletionStatus(progressId);
  }

  @override
  Future<Mou?> getMouData(String progressKpltId) async {
    final map = await remoteDataSource.getMouData(progressKpltId);
    if (map == null) return null;
    return Mou.fromMap(map);
  }
}

