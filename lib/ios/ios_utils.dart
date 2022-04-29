import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class IOSUtils {
  static Future<bool> unzip(String zipPath, [Directory? destination]) async {
    destination ??= await getTemporaryDirectory();
    zipPath = zipPath.split('file://').last;
    final zipFile = File(Uri.decodeFull(zipPath));
    try {
      await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: destination);
      return true;
    } catch (e) {
      debugPrint("Error unzipping $zipPath: $e");
      return false;
    }
  }

  static Future<List<String>> readFile([String? path]) async {
    path ??= (await getTemporaryDirectory()).path + '/_chat.txt';
    final file = File(path);
    List<String> lines = await file.readAsLines();
    deleteFile(path);
    return lines;
  }

  static Future<bool> deleteFile(String path) async {
    final file = File(path);
    await file.delete();
    return await file.exists();
  }
}
