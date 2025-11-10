import 'dart:io';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileService {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  static Future<void> openOrDownloadFile(
    BuildContext context,
    String? pathOrUrl,
  ) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dokumen tidak tersedia.')),
        );
      }
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final localFileName = pathOrUrl.split('/').last;
      final localPath = '${directory.path}/$localFileName';
      final localFile = File(localPath);

      if (await localFile.exists()) {
        await OpenFilex.open(localPath);
      } else {
        if (context.mounted) showLoadingDialog(context);

        final supabase = Supabase.instance.client;
        final fileBytes = await supabase.storage
            .from('file_storage')
            .download(pathOrUrl);

        if (context.mounted) Navigator.of(context).pop();

        await localFile.writeAsBytes(fileBytes, flush: true);
        await OpenFilex.open(localPath);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh file: $e')),
        );
      }
    }
  }
}