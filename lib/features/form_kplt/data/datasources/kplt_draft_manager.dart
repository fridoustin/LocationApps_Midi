import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_state.dart';
import 'package:path_provider/path_provider.dart';

class KpltDraftManager {
  Future<Directory> _getDraftsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final draftsDirectory = Directory('${directory.path}/kplt_drafts');
    
    // Jika direktori belum ada, buat
    if (!await draftsDirectory.exists()) {
      await draftsDirectory.create(recursive: true);
    }
    return draftsDirectory;
  }

  Future<File> _getDraftFile(String ulokId) async {
    final directory = await _getDraftsDirectory();
    return File('${directory.path}/kplt_draft_$ulokId.json');
  }

  Future<void> saveDraft(KpltFormState state) async {
    final file = await _getDraftFile(state.ulokId);
    final jsonString = jsonEncode(state.toJson());
    debugPrint("--- SAVING DRAFT ---");
    debugPrint("File path: ${file.path}");
    await file.writeAsString(jsonString);
  }

  // Fungsi untuk memuat state dari file JSON
  Future<KpltFormState?> loadDraft(String ulokId) async {
    try {
      final file = await _getDraftFile(ulokId);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          final jsonMap = jsonDecode(jsonString);
          return KpltFormState.fromJson(jsonMap);
        }
        return null;
      }
      return null; 
    } catch (e) {
      debugPrint("Error loading KPLT draft: $e");
      return null; 
    }
  }
  
  Future<void> deleteDraft(String ulokId) async {
    final file = await _getDraftFile(ulokId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<KpltFormState>> getAllDrafts() async {
    final draftsDirectory = await _getDraftsDirectory();
    final List<KpltFormState> drafts = [];

    try {
      final List<FileSystemEntity> files = draftsDirectory.listSync();
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            final json = jsonDecode(content) as Map<String, dynamic>;
            drafts.add(KpltFormState.fromJson(json));
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading all KPLT drafts: $e');
    }
    
    return drafts;
  }
}