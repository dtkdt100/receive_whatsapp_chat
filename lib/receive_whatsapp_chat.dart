import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receive_whatsapp_chat/share/share.dart';
import 'package:receive_whatsapp_chat/utils/logger.dart';
import 'package:receive_whatsapp_chat/utils/zip_utils.dart';
import 'chat_analyzer/chat_analyzer.dart';
import 'models/chat_content.dart';

export 'models/models.dart';

///I used Duarte Silveira share package. See: https://github.com/d-silveira/flutter-share.
/// We could not use his package because we needed to perform changes and it wasn't sound null safety.
/// There is a credit to him and there will be throughout the whole package.

abstract class ReceiveWhatsappChat<T extends StatefulWidget> extends State<T> {
  /// Stream [stream] for listener
  static const stream = EventChannel('plugins.flutter.io/receiveshare');

  /// Method Channel [methodChannel] for analyzing the chat
  static const MethodChannel methodChannel =
      MethodChannel('com.whatsapp.chat/chat');

  /// Can Receive the chat or not
  bool shareReceiveEnabled = false;

  /// StreamSubscription [_shareReceiveSubscription] for listener
  StreamSubscription? _shareReceiveSubscription;

  /// We need to enable [shareReceiveEnabled] at first
  @override
  void initState() {
    super.initState();

    /// For sharing images coming from outside the app while the app is closed
    if (Platform.isIOS) {
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then(_receiveShareInternalIOS);
    }

    Future.delayed(const Duration(seconds: 1), () {
      enableShareReceiving();
    });
  }

  /// Enable the receiving
  void enableShareReceiving() {
    if (shareReceiveEnabled) return;
    if (Platform.isAndroid) {
      _shareReceiveSubscription ??=
          stream.receiveBroadcastStream().listen(_receiveShareInternalAndroid);
    } else if (Platform.isIOS) {
      _shareReceiveSubscription ??= ReceiveSharingIntent.instance
          .getMediaStream()
          .listen(_receiveShareInternalIOS);
    }
    shareReceiveEnabled = true;
  }

  /// Disable the receiving
  void disableShareReceiving() {
    if (_shareReceiveSubscription != null) {
      _shareReceiveSubscription!.cancel();
      _shareReceiveSubscription = null;
    }
    shareReceiveEnabled = false;
  }

  /// Receive the share Android - in our case we receive a zip file url: file:///private/var/mobile/Containers/Shared/AppGroup/...
  void _receiveShareInternalIOS(List<SharedMediaFile> shared) {
    if (shared.isEmpty) return;
    receiveShareIOS(shared).catchError((Object e, StackTrace st) {
      Logger.error('Failed to receive the chat on iOS', e, st);
      Error.throwWithStackTrace(e, st);
    });
  }

  /// Receive the share Android - in our case we receive a content url: content://com.whatsapp.provider.media/export_chat/972537739211@s.whatsapp.net/e26757...
  void _receiveShareInternalAndroid(dynamic shared) {
    final Share share;
    try {
      share = Share.fromReceived(shared);
    } catch (e, st) {
      Logger.error(
          'Unexpected share payload (keys: ${shared is Map ? shared.keys.toList() : shared.runtimeType})',
          e,
          st);
      rethrow;
    }
    receiveShareAndroid(share).catchError((Object e, StackTrace st) {
      Logger.error('Failed to receive the chat on Android', e, st);
      Error.throwWithStackTrace(e, st);
    });
  }

  /// In iOS WhatsApp sends us a zip file.
  /// We need to unzip the file, read it and sent it to the [ChatAnalyzer.analyze]
  Future<void> receiveShareIOS(List<SharedMediaFile> shared) async {
    String path = Uri.decodeFull(shared[0].path);
    if (!isWhatsAppChatUrl(path)) {
      Logger.error('Shared file is not a WhatsApp chat export '
          '(${Logger.shape(path, 80)})');
      throw Exception("Not a WhatsApp chat url");
    }
    if (!await ZipUtils.iosUnzip(path)) throw Exception("Unzip failed");
    List<String> chat = await ZipUtils.readFile("_chat.txt");
    chat.insert(0, path.split('/').last);
    receiveChatContent(ChatAnalyzer.analyze(chat));
  }

  /// Calling the [methodChannel.invokeMethod] and receive [List<String>] as a result.
  /// Sent it to analyze at [ChatAnalyzer.analyze].
  /// Calling an abstract function [receiveChatContent] with [ChatContent] variable.
  Future<void> receiveShareAndroid(Share shared) async {
    final path = shared.path;
    if (path.isEmpty || shared.text.isEmpty) {
      Logger.error('Share is missing the file uri or the chat name '
          '(has uri: ${path.isNotEmpty}, has name: ${shared.text.isNotEmpty}, '
          'type: ${shared.mimeType})');
    } else if (!isWhatsAppChatUrl(path)) {
      Logger.warning('Shared uri is not from WhatsApp\'s export provider '
          '(${Logger.shape(path, 80)}), trying anyway');
    }
    if (!await ZipUtils.androidUnzip(path)) throw Exception("Unzip failed");
    List<String> chat = await ZipUtils.readFile("${shared.text}.txt");
    chat.insert(0, shared.text);
    receiveChatContent(ChatAnalyzer.analyze(chat));
  }

  /// Check if the url is a WhatsApp chat url
  bool isWhatsAppChatUrl(String url) {
    if (Platform.isAndroid) {
      // WhatsApp has used both .../export_chat/ and .../export_chat_folder/
      return url
          .startsWith("content://com.whatsapp.provider.media/export_chat");
    } else if (Platform.isIOS) {
      return url
          .startsWith("file:///private/var/mobile/Containers/Shared/AppGroup/");
    }
    return false;
  }

  /// Abstract function calling after we receive and analyze the chat
  void receiveChatContent(ChatContent chatContent);
}
