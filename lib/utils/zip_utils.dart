import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uri_to_file/uri_to_file.dart';

class ZipUtils {
  /// Android content provider has to resolve with uri_to_file package
  static Future<bool> androidUnzip(String zipPath,
      [Directory? destination]) async {
    return await _unzip(await toFile(zipPath), destination);
  }

  /// iOS has to resolve with file://
  static Future<bool> iosUnzip(String zipPath, [Directory? destination]) async {
    return await _unzip(File(zipPath.split('file://').last), destination);
  }

  /// Un zip the zip file from WhatsApp
  static Future<bool> _unzip(File zipFile, [Directory? destination]) async {
    destination ??=
        Directory("${(await getTemporaryDirectory()).path}/unzipped");

    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: destination);
      return true;
    } catch (e) {
      debugPrint("Error unzipping ${zipFile.path}: $e");
      return false;
    }
  }

  /// Read the txt file inside the extracted zip file
  static Future<List<String>> readFile(String fileName) async {
    // If the whatsapp chat is shared with media, the unzipped folder will contain the media files,
    // so we need to read the txt file from the unzipped folder and list all the images and do something
    // with them
    String path = '${(await getTemporaryDirectory()).path}/unzipped/$fileName';
    File file = File(path);
    List<String> lines = await file.readAsLines();
    await _deleteDir(Directory("${(await getTemporaryDirectory()).path}/unzipped"));
    return lines;
  }

  /// Delete the file after we read it
  static Future<bool> _deleteDir(Directory dir) async {
    await dir.delete(recursive: true);
    return await dir.exists();
  }
}
