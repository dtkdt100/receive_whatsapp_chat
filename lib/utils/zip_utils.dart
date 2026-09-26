import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

import 'logger.dart';

class ZipUtils {
  static const MethodChannel _channel = MethodChannel('com.whatsapp.chat/chat');

  /// Android content provider uri has to be copied to a local file first
  static Future<bool> androidUnzip(String zipPath,
      [Directory? destination]) async {
    final String? path;
    try {
      path = await _channel
          .invokeMethod<String>('contentUriToFile', {'uri': zipPath});
    } on PlatformException catch (e, st) {
      Logger.error(
          'Could not copy the shared content uri to a file '
          '(code: ${e.code}, uri scheme: ${Uri.tryParse(zipPath)?.scheme})',
          e.message,
          st);
      return false;
    }
    if (path == null) {
      Logger.error('contentUriToFile returned null for the shared uri');
      return false;
    }
    return await _unzip(File(path), destination);
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
    } catch (e, st) {
      final exists = zipFile.existsSync();
      Logger.error(
          'Unzip failed (file exists: $exists'
          '${exists ? ', size: ${zipFile.lengthSync()} bytes' : ''})',
          e,
          st);
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
    if (!file.existsSync()) {
      // The expected name depends on the WhatsApp version and phone language,
      // so log what the export actually contains.
      final files = Directory(file.parent.path)
          .listSync()
          .map((f) => f.path.split('/').last)
          .toList();
      Logger.error('Chat file "${Logger.shape(fileName)}" not found in the '
          'export. Files in the export: ${files.map(Logger.shape).toList()}');
    }
    List<String> lines = await file.readAsLines();
    if (lines.isEmpty) Logger.warning('Chat file "$fileName" is empty');
    await _deleteDir(
        Directory("${(await getTemporaryDirectory()).path}/unzipped"));
    return lines;
  }

  /// Delete the file after we read it
  static Future<bool> _deleteDir(Directory dir) async {
    await dir.delete(recursive: true);
    return await dir.exists();
  }
}
