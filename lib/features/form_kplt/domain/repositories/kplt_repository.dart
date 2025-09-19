import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';

abstract class KpltRepository {
  Future<List<FormKPLT>> getRecentKplt(String query);
  Future<List<FormKPLT>> getKpltNeedInput(String query);
  Future<List<FormKPLT>> getHistoryKplt(String query);
}