// Copyright 2018 Duarte Silveira
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'share_type.dart';

/// Summoning a platform share sheet.
class Share {
  static const String titleString = "title";
  static const String textString = "text";
  static const String pathString = "path";
  static const String typeString = "type";
  static const String isMultipleString = "is_multiple";

  final ShareType? mimeType;
  final String title;
  final String text;
  final String path;
  final List<Share> shares;

  Share.nullType()
      : mimeType = null,
        title = '',
        text = '',
        path = '',
        shares = const [];

  const Share.plainText({required this.title, required this.text})
      : mimeType = ShareType.typePlainText,
        path = '',
        shares = const [];

  /// The type of our WhatsApp chat
  const Share.file(
      {this.mimeType = ShareType.typeFile,
      required this.title,
      required this.path,
      this.text = ''})
      : assert(mimeType != null),
        shares = const [];

  const Share.image(
      {this.mimeType = ShareType.typeImage,
      required this.title,
      required this.path,
      this.text = ''})
      : assert(mimeType != null),
        shares = const [];

  const Share.multiple(
      {this.mimeType = ShareType.typeFile,
      required this.title,
      required this.shares})
      : text = '',
        path = '';

  static Share fromReceived(Map received) {
    assert(received.containsKey(typeString));
    ShareType type = ShareType.fromMimeType(received[typeString]);
    if (received.containsKey(isMultipleString)) {
      List<Share> receivedShares = [];
      for (var i = 0; i < received.length - 2; i++) {
        receivedShares.add(Share.file(path: received["$i"], title: ''));
      }
      if (received.containsKey(titleString)) {
        return Share.multiple(
            mimeType: type,
            title: received[titleString],
            shares: receivedShares);
      } else {
        return Share.multiple(
            mimeType: type, shares: receivedShares, title: '');
      }
    } else {
      return _fromReceivedSingle(received, type)!;
    }
  }

  static Share? _fromReceivedSingle(Map received, ShareType type) {
    switch (type) {
      case ShareType.typePlainText:
        if (received.containsKey(titleString)) {
          return Share.plainText(
              title: received[titleString], text: received[textString]);
        } else {
          return Share.plainText(text: received[textString], title: '');
        }

      case ShareType.typeImage:
        if (received.containsKey(titleString)) {
          if (received.containsKey(textString)) {
            return Share.image(
                path: received[pathString],
                title: received[titleString],
                text: received[textString]);
          } else {
            return Share.image(
                path: received[pathString],
                text: received[titleString],
                title: '');
          }
        } else {
          return Share.image(path: received[pathString], title: '');
        }

      case ShareType.typeFile:
        if (received.containsKey(titleString)) {
          if (received.containsKey(textString)) {
            return Share.file(
                path: received[pathString],
                title: received[titleString],
                text: received[textString]);
          } else {
            return Share.file(
                path: received[pathString],
                text: received[titleString],
                title: '');
          }
        } else {
          return Share.file(path: received[pathString], title: '');
        }
    }
    return null;
  }

  bool get isNull => mimeType == null;

  bool get isMultiple => shares.isNotEmpty;

  @override
  String toString() {
    return 'Share{' +
        (isNull
            ? 'null }'
            : 'mimeType: $mimeType, title: $title, text: $text, path: $path, shares: $shares}');
  }
}
