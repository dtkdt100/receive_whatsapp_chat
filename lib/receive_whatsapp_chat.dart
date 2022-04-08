import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:receive_whatsapp_chat/share/share.dart';
import 'chat_analyzer/chat_analyzer.dart';
import 'models/chat_content.dart';

export 'models/models.dart';

///I used Duarte Silveira share package. See: https://github.com/d-silveira/flutter-share.
/// We could not use his package because we needed to perform changes and it wasn't sound null safety.
/// There is a credit to him and there will be throughout the whole package.

abstract class ReceiveWhatsappChat<T extends StatefulWidget> extends State<T> {
  /// Stream [stream] for listener
  static const stream = EventChannel('plugins.flutter.io/receiveshare');

  /// Method Channel [_methodChannel] for analyzing the chat
  static const MethodChannel _methodChannel =
      MethodChannel('com.whatsapp.chat/chat');

  /// Can Receive the chat or not
  bool shareReceiveEnabled = false;

  /// StreamSubscription [_shareReceiveSubscription] for listener
  StreamSubscription? _shareReceiveSubscription;

  /// We need to enable [shareReceiveEnabled] at first
  @override
  void initState() {
    enableShareReceiving();
    super.initState();
  }

  @override
  void dispose() {
    disableShareReceiving();
    super.dispose();
  }

  /// Enable the receiving
  void enableShareReceiving() {
    _shareReceiveSubscription ??=
        stream.receiveBroadcastStream().listen(_receiveShareInternal);
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

  /// Receive the share - in our case we receive a content url: content://com.whatsapp.provider.media/export_chat/972537739211@s.whatsapp.net/e26757...
  void _receiveShareInternal(dynamic shared) {
    debugPrint("Share received - $shared");
    receiveShare(Share.fromReceived(shared));
  }

  /// Calling the [_methodChannel.invokeMethod] and receive [List<String>] as a result.
  /// Sent it to analyze at [ChatAnalyzer.analyze].
  /// Calling an abstract function [receiveChatContent] with [ChatContent] variable.
  Future<void> receiveShare(Share shared) async {
    List<String> chat = List<String>.from(await _methodChannel.invokeMethod(
        "analyze", <String, dynamic>{"data": shared.shares[0].path}));
    receiveChatContent(ChatAnalyzer.analyze(chat));
  }

  /// Abstract function calling after we receive and analyze the chat
  void receiveChatContent(ChatContent chatContent);
}
