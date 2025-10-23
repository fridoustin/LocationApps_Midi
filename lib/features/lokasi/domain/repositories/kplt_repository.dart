import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';

abstract class KpltRepository {
  Future<List<FormKPLT>> getRecentKplt(String query, {KpltFilter? filter});
  Future<List<FormKPLT>> getKpltNeedInput(String query, {KpltFilter? filter});
  Future<List<FormKPLT>> getHistoryKplt(String query, {KpltFilter? filter});
  Future<void> submitKplt(KpltFormData formData);
  Future<FormKPLT> getKpltById(String kpltId); 
  Future<void> updateKplt(String kpltId, Map<String, dynamic> data, {required FormKPLT originalKplt});
}