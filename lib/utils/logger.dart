import 'package:flutter/foundation.dart';

/// Debug-only logging for the failure points worth monitoring.
///
/// Every line starts with [tag], so it can be filtered with
/// `flutter logs | grep receive_whatsapp_chat`. Nothing is printed in release.
class Logger {
  static const String tag = '[receive_whatsapp_chat]';

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    debugPrint('$tag ERROR $message${error == null ? '' : ' -> $error'}');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, maxFrames: 10);
    }
  }

  static void warning(String message) {
    if (!kDebugMode) return;
    debugPrint('$tag WARNING $message');
  }

  /// Masks a chat line so its format can be logged without its content:
  /// letters become `a`, digits become `9`, and the line is truncated.
  /// e.g. `[25/04/2022, 10:17:07] Dolev: Hi` -> `[99/99/9999, 99:99:99] aaaaa: aa`
  static String shape(String line, [int maxLength = 60]) {
    final masked = line
        .replaceAll(RegExp(r'\p{L}', unicode: true), 'a')
        .replaceAll(RegExp(r'\p{N}', unicode: true), '9');
    return masked.length <= maxLength
        ? masked
        : '${masked.substring(0, maxLength)}…';
  }
}
