import 'dart:convert';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UlokFormLocalDataSource {
  static const _draftsKey = 'ulok_drafts';

  Future<void> saveDraft(UlokFormData data) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    // Gunakan 'localId'
    drafts.removeWhere((d) => d.localId == data.localId);
    drafts.add(data);
    
    // Gunakan 'toLocalJson()'
    final draftsJson = drafts.map((d) => jsonEncode(d.toLocalJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }

  Future<List<UlokFormData>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(_draftsKey) ?? [];
    return draftsJson
        .map((jsonString) => UlokFormData.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> deleteDraft(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    // Gunakan 'localId'
    drafts.removeWhere((d) => d.localId == localId);
    
    // Gunakan 'toLocalJson()'
    final draftsJson = drafts.map((d) => jsonEncode(d.toLocalJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }
}