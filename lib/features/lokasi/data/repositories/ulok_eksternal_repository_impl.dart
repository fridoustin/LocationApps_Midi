import 'package:midi_location/features/lokasi/data/datasources/ulok_eksternal_remote_datasource.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_eksternal.dart';
import 'package:midi_location/features/lokasi/domain/repositories/ulok_eksternal_repository.dart';

class UlokEksternalRepositoryImpl implements UlokEksternalRepository {
  final UlokEksternalRemoteDataSource _remoteDataSource;

  UlokEksternalRepositoryImpl(this._remoteDataSource);

  @override
  Future<UlokEksternal> getUlokEksternalById(String id) async {
    final data = await _remoteDataSource.getUlokEksternalById(id);
    return UlokEksternal.fromMap(data);
  }
}