
// Implementasi dari kontrak repository
import 'package:midi_location/features/wilayah/data/datasources/wilayah_remote_datasource.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/domain/repositories/wilayah_repository.dart';

class WilayahRepositoryImpl implements WilayahRepository {
  final WilayahRemoteDataSource _dataSource;
  WilayahRepositoryImpl(this._dataSource);

  @override
  Future<List<WilayahEntity>> getProvinces() => _dataSource.getProvinces();

  @override
  Future<List<WilayahEntity>> getRegencies(String provinceCode) =>
    _dataSource.getRegencies(provinceCode);

  @override
  Future<List<WilayahEntity>> getDistricts(String regencyCode) =>
    _dataSource.getDistricts(regencyCode);

  @override
  Future<List<WilayahEntity>> getVillages(String districtCode) =>
    _dataSource.getVillages(districtCode);
}
