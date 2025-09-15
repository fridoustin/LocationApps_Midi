import 'package:midi_location/features/ulok/data/datasources/ulok_form_local_datasource.dart';
import 'package:midi_location/features/ulok/data/datasources/ulok_form_remote_datasource.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_form_repository.dart';

class UlokFormRepositoryImpl implements UlokFormRepository {
  final UlokFormRemoteDataSource _remoteDataSource;
  final UlokFormLocalDataSource _localDataSource;

  UlokFormRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<void> submitUlok(UlokFormData data, String branchId) => _remoteDataSource.submitUlok(data, branchId);
      
  @override
  Future<void> updateUlok(String ulokId, UlokFormData data) => _remoteDataSource.updateUlok(ulokId, data);

  @override
  Future<void> saveDraft(UlokFormData data) => _localDataSource.saveDraft(data);
  
  @override
  Future<List<UlokFormData>> getDrafts() => _localDataSource.getDrafts();
  
  @override
  Future<void> deleteDraft(String localId) => _localDataSource.deleteDraft(localId);
}
