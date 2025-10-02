import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';

class KpltRepositoryImpl implements KpltRepository {
  final KpltRemoteDatasource dataSource;
  KpltRepositoryImpl(this.dataSource);

  @override
  Future<List<FormKPLT>> getRecentKplt(String query) async {
    final data = await dataSource.getRecentKplt(query: query);
    return data.map((map) => FormKPLT.fromJoinedKpltMap(map)).toList();
  }

  @override
  Future<List<FormKPLT>> getKpltNeedInput(String query) async {
    final data = await dataSource.getKpltNeedInput(query: query);
    return data.map((map) => FormKPLT.fromUlokMap(map)).toList();
  }

  @override
  Future<List<FormKPLT>> getHistoryKplt(String query) async {
    final data = await dataSource.getHistoryKplt(query: query);
    return data.map((map) => FormKPLT.fromJoinedKpltMap(map)).toList();
  }

  @override
  Future<void> submitKplt(KpltFormData formData) async {
    try {
      await dataSource.submitKplt(formData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormKPLT> getKpltById(String kpltId) async {
    final map = await dataSource.getKpltById(kpltId);
    return FormKPLT.fromKpltDetailMap(map); 
  }
}