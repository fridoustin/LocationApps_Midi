import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:path_provider/path_provider.dart';

class KpltDraftManager {
  // Mendapatkan path file draft yang unik untuk setiap ulok
  Future<File> _getDraftFile(String ulokId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/kplt_draft_$ulokId.json');
  }

  // Fungsi untuk menyimpan state ke file JSON
  Future<void> saveDraft(KpltFormState state) async {
    final file = await _getDraftFile(state.ulokId);
    final jsonString = jsonEncode(state.toJson());
    debugPrint("--- SAVING DRAFT ---");
    debugPrint("File path: ${file.path}");
    debugPrint("JSON content: $jsonString");
    await file.writeAsString(jsonString);
  }

  // Fungsi untuk memuat state dari file JSON
  Future<KpltFormState?> loadDraft(String ulokId) async {
    try {
      final file = await _getDraftFile(ulokId);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString);
        return KpltFormState.fromJson(jsonMap);
      }
      return null; // Tidak ada draft
    } catch (e) {
      return null; // Error saat membaca file
    }
  }
  
  // Fungsi untuk menghapus draft (setelah berhasil submit)
  Future<void> deleteDraft(String ulokId) async {
    final file = await _getDraftFile(ulokId);
    if (await file.exists()) {
      await file.delete();
    }
  }
}