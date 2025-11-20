import 'package:midi_location/features/lokasi/domain/entities/ulok_eksternal.dart';

abstract class UlokEksternalRepository {
  Future<UlokEksternal> getUlokEksternalById(String id);
}