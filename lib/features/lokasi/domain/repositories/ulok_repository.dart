import 'package:midi_location/features/lokasi/domain/entities/ulok_filter.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';

abstract class UlokRepository {
  Future<List<UsulanLokasi>> getRecentUlok({required String query, required UlokFilter filter});
  Future<List<UsulanLokasi>> getHistoryUlok({required String query, required UlokFilter filter});
  Future<UsulanLokasi> getUlokById(String ulokId);
}