import 'dart:io';

Future<bool> fileExists(File file) async {
  return await file.exists();
}