import 'dart:convert';
import 'package:midi_location/core/utils/file_utils.dart';
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
    
    final List<UlokFormState> drafts = [];

    for (final jsonString in draftsJson) {
      try {
        final json = jsonDecode(jsonString);
        if (json['formUlokPdfPath'] != null) {
          json['formUlokPdfPath'] =
              safeFile(json['formUlokPdfPath'])?.path; 
        }

        // skip draft yang korup atau tidak kompatibel
        final draft = UlokFormState.fromJson(json);
        drafts.add(draft);

      } catch (e) {
        // Skip JSON corrupt tanpa crash
        continue;
      }
    }

    return drafts;
  }

  Future<void> deleteDraft(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();

    drafts.removeWhere((d) => d.localId == localId);

    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }
}
