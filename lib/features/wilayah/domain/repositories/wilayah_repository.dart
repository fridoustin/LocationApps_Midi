
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';

abstract class WilayahRepository {
  Future<List<WilayahEntity>> getProvinces();
  Future<List<WilayahEntity>> getRegencies(String provinceCode);
  Future<List<WilayahEntity>> getDistricts(String regencyCode);
  Future<List<WilayahEntity>> getVillages(String districtCode);
}
