import 'dart:io';

File? safeFile(String? path) {
  if (path == null) return null;
  final file = File(path);
  return file.existsSync() ? file : null;
}
