import 'dart:io';

import 'package:flutter/material.dart';
import 'package:midi_location/features/form_kplt/data/datasources/kplt_remote_datasource.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltRepositoryImpl implements KpltRepository {
  final KpltRemoteDatasource dataSource;
  KpltRepositoryImpl(this.dataSource);

  @override
  Future<List<FormKPLT>> getRecentKplt(String query) async {
    final data = await dataSource.getRecentKplt(query: query);
    return data.map((map) => FormKPLT.fromJoinedKpltMap(map)).toList();
  }

  @override
  Future<List<FormKPLT>> getKpltNeedInput(String query) async {
    final data = await dataSource.getKpltNeedInput(query: query);
    return data.map((map) => FormKPLT.fromUlokMap(map)).toList();
  }

  @override
  Future<List<FormKPLT>> getHistoryKplt(String query) async {
    final data = await dataSource.getHistoryKplt(query: query);
    return data.map((map) => FormKPLT.fromJoinedKpltMap(map)).toList();
  }

  @override
  Future<void> submitKplt(KpltFormData formData) async {
    try {
      await dataSource.submitKplt(formData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormKPLT> getKpltById(String kpltId) async {
    final map = await dataSource.getKpltById(kpltId);
    return FormKPLT.fromKpltDetailMap(map); 
  }
  
  @override
  Future<void> updateKplt(String kpltId, Map<String, dynamic> mixedData, {required FormKPLT originalKplt}) async {
    final List<String> newUploadedFilePaths = [];
    final List<String> oldFilePathsToDelete = [];

    try {
      final dbData = <String, dynamic>{};
      final filesToUpload = <String, File>{};

      mixedData.forEach((key, value) {
        if (value is File) {
          filesToUpload[key] = value;
        } else {
          dbData[key] = value;
        }
      });

      if (filesToUpload.isNotEmpty) {
        for (final entry in filesToUpload.entries) {
          final columnName = entry.key;
          final file = entry.value;
          final ulokId = originalKplt.ulokId;

          final fileExtension = file.path.split('.').last;
          final newFilePath = '$ulokId/kplt/${DateTime.now().millisecondsSinceEpoch}_$columnName.$fileExtension';

          await Supabase.instance.client.storage.from('file_storage').upload(
            newFilePath,
            file,
            fileOptions: FileOptions(contentType: lookupMimeType(file.path)),
          );

          newUploadedFilePaths.add(newFilePath);
          dbData[columnName] = newFilePath;

          String? oldPath;
          switch (columnName) {
            case 'pdf_foto': oldPath = originalKplt.pdfFoto; break;
            case 'counting_kompetitor': oldPath = originalKplt.countingKompetitor; break;
            case 'pdf_pembanding': oldPath = originalKplt.pdfPembanding; break;
            case 'pdf_kks': oldPath = originalKplt.pdfKks; break;
            case 'excel_fpl': oldPath = originalKplt.excelFpl; break;
            case 'excel_pe': oldPath = originalKplt.excelPe; break;
            case 'pdf_form_ukur': oldPath = originalKplt.pdfFormUkur; break;
            case 'video_traffic_siang': oldPath = originalKplt.videoTrafficSiang; break;
            case 'video_traffic_malam': oldPath = originalKplt.videoTrafficMalam; break;
            case 'video_360_siang': oldPath = originalKplt.video360Siang; break;
            case 'video_360_malam': oldPath = originalKplt.video360Malam; break;
            case 'peta_coverage': oldPath = originalKplt.petaCoverage; break;
          }
          if (oldPath != null && oldPath.isNotEmpty) {
            oldFilePathsToDelete.add(oldPath);
          }
        }
      }

      if (dbData.isNotEmpty) {
        await dataSource.updateKplt(kpltId, dbData);
      }

      if (oldFilePathsToDelete.isNotEmpty) {
        await Supabase.instance.client.storage.from('file_storage').remove(oldFilePathsToDelete);
        debugPrint("Successfully deleted old files: $oldFilePathsToDelete");
      }

    } catch (e) {
      debugPrint("An error occurred during update: $e. Rolling back new uploads...");
      if (newUploadedFilePaths.isNotEmpty) {
        await Supabase.instance.client.storage.from('file_storage').remove(newUploadedFilePaths);
        debugPrint("Rollback successful. Deleted new files: $newUploadedFilePaths");
      }
      rethrow;
    }
  }
}