import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:midi_location/core/utils/file_utils.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt_state.dart';
import 'package:path_provider/path_provider.dart';

class KpltDraftManager {
  Future<Directory> _getDraftsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final draftsDirectory = Directory('${directory.path}/kplt_drafts');
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
    final sanitized = state.copyWith(
      lastEdited: DateTime.now(),
    );
    await file.writeAsString(jsonEncode(sanitized.toJson()));
  }

  Future<KpltFormState?> loadDraft(String ulokId) async {
    try {
      final file = await _getDraftFile(ulokId);
      if (!await file.exists()) return null;
      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) return null;
      final json = jsonDecode(jsonString);
      _sanitizeFilePaths(json);
      return KpltFormState.fromJson(json);
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
    final directory = await _getDraftsDirectory();
    final List<KpltFormState> drafts = [];

    try {
      final entries = directory.listSync();
      for (var file in entries) {
        if (file is! File || !file.path.endsWith(".json")) continue;
        try {
          final content = await file.readAsString();
          if (content.isEmpty) continue;
          final json = jsonDecode(content);
          _sanitizeFilePaths(json);
          drafts.add(KpltFormState.fromJson(json));
        } catch (e) {
          debugPrint("Skip corrupt KPLT draft: $e");
        }
      }
      drafts.sort((a, b) {
        final aTime = a.lastEdited?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastEdited?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      debugPrint("Error listing KPLT drafts: $e");
    }

    return drafts;
  }

  void _sanitizeFilePaths(Map<String, dynamic> json) {
    final keys = [
      'pdfFotoPath',
      'countingKompetitorPath',
      'pdfPembandingPath',
      'pdfKksPath',
      'excelFplPath',
      'excelPePath',
      'videoTrafficSiangPath',
      'videoTrafficMalamPath',
      'video360SiangPath',
      'video360MalamPath',
      'petaCoveragePath',
    ];

    for (final key in keys) {
      if (json[key] != null) {
        json[key] = safeFile(json[key])?.path;
      }
    }
  }
}
