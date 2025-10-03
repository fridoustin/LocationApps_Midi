import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';

abstract class KpltRepository {
  Future<List<FormKPLT>> getRecentKplt(String query);
  Future<List<FormKPLT>> getKpltNeedInput(String query);
  Future<List<FormKPLT>> getHistoryKplt(String query);
  Future<void> submitKplt(KpltFormData formData);
  Future<FormKPLT> getKpltById(String kpltId); 
  Future<void> updateKplt(String kpltId, Map<String, dynamic> data, {required FormKPLT originalKplt});
}