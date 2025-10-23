import 'dart:convert';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UlokFormLocalDataSource {
  static const _draftsKey = 'ulok_drafts';

  Future<void> saveDraft(UlokFormState data) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    drafts.removeWhere((d) => d.localId == data.localId);
    drafts.add(data);
    
    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }

  Future<List<UlokFormState>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(_draftsKey) ?? [];
    return draftsJson
        .map((jsonString) => UlokFormState.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> deleteDraft(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    drafts.removeWhere((d) => d.localId == localId);
    
    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }
}