import 'package:midi_location/features/ulok/data/datasources/ulok_form_remote_datasource.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/repositories/ulok_form_repository.dart';

class UlokFormRepositoryImpl implements UlokFormRepository {
  final UlokFormRemoteDataSource _dataSource;
  UlokFormRepositoryImpl(this._dataSource);

  @override
  Future<void> submitUlok(UlokFormData data, String branchId) =>
      _dataSource.submitUlok(data, branchId);
}
