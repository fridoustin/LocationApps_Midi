import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form_state.dart';

abstract class UlokFormRepository {
  Future<void> submitUlok(UlokFormData data, String branchId);
  Future<void> updateUlok(String ulokId, UlokFormData data);

  Future<void> saveDraft(UlokFormState data);
  Future<List<UlokFormState>> getDrafts();
  Future<void> deleteDraft(String localId);
}
