import 'dart:convert';
import 'dart:io';
import 'fileExists.dart';

Future<File> getOrCreateFile(String path) async {
  final file = File(path);
  if (!await fileExists(file)) {
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode([]));
  }
  return file;
}