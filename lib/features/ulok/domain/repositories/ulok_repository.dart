import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';

abstract class UlokRepository {
  Future<List<UsulanLokasi>> getRecentUlok(String query);
  Future<List<UsulanLokasi>> getHistoryUlok(String query);
}