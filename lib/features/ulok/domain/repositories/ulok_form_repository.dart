import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';

abstract class UlokFormRepository {
  Future<void> submitUlok(UlokFormData data, String branchId);
  Future<void> updateUlok(String ulokId, UlokFormData data);
}
