import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receive_whatsapp_chat/share/share.dart';
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
    /// For sharing images coming from outside the app while the app is closed
    if (Platform.isIOS) {
      ReceiveSharingIntent.getInitialMedia().then(_receiveShareInternalIOS);
    }
    enableShareReceiving();
    super.initState();
  }

  /// Enable the receiving
  void enableShareReceiving() {
    if (Platform.isAndroid) {
      _shareReceiveSubscription ??=
          stream.receiveBroadcastStream().listen(_receiveShareInternalAndroid);
    } else if (Platform.isIOS) {
      _shareReceiveSubscription ??= ReceiveSharingIntent.getMediaStream()
          .listen(_receiveShareInternalIOS);
    }
    shareReceiveEnabled = true;
    debugPrint("enabled share receiving");
  }

  /// Disable the receiving
  void disableShareReceiving() {
    if (_shareReceiveSubscription != null) {
      _shareReceiveSubscription!.cancel();
      _shareReceiveSubscription = null;
    }
    shareReceiveEnabled = false;
    debugPrint("disabled share receiving");
  }

  /// Receive the share Android - in our case we receive a zip file url: file:///private/var/mobile/Containers/Shared/AppGroup/...
  void _receiveShareInternalIOS(List<SharedMediaFile> shared) {
    debugPrint("Share received - $shared");
    if (shared.isNotEmpty) receiveShareIOS(shared);
  }

  /// Receive the share Android - in our case we receive a content url: content://com.whatsapp.provider.media/export_chat/972537739211@s.whatsapp.net/e26757...
  void _receiveShareInternalAndroid(dynamic shared) {
    debugPrint("Share received - $shared");
    receiveShareAndroid(Share.fromReceived(shared));
  }

  /// In iOS WhatsApp sends us a zip file.
  /// We need to unzip the file, read it and sent it to the [ChatAnalyzer.analyze]
  Future<void> receiveShareIOS(List<SharedMediaFile> shared) async {
    String path = Uri.decodeFull(shared[0].path);
    if (!isWhatsAppChatUrl(path)) throw Exception("Not a WhatsApp chat url");
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
    if (!await ZipUtils.androidUnzip(path)) throw Exception("Unzip failed");
    List<String> chat = await ZipUtils.readFile("${shared.text}.txt");
    chat.insert(0, shared.text);
    receiveChatContent(ChatAnalyzer.analyze(chat));
  }

  /// Check if the url is a WhatsApp chat url
  bool isWhatsAppChatUrl(String url) {
    if (Platform.isAndroid) {
      return url
          .startsWith("content://com.whatsapp.provider.media/export_chat/");
    } else if (Platform.isIOS) {
      return url
          .startsWith("file:///private/var/mobile/Containers/Shared/AppGroup/");
    }
    return false;
  }

  /// Abstract function calling after we receive and analyze the chat
  void receiveChatContent(ChatContent chatContent);
}
