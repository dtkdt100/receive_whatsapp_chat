import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';
import 'package:collection/collection.dart';

/// Class for the whole settings of the chat
/// [chatName] - name of the chat
/// [members] - list of members of the chat
/// [messages] - list of [MessageContent] in the chat
/// [sizeOfChat] - size of the chat
/// [msgsPerMember] - number of messages per member
/// [indexesPerMember] - list of indexes of messages per member
/// [imagesPaths] - If you chose to export WhatsApp chat with media, this list will contain the paths of the images
class ChatContent {
  ChatContent({
    required this.members,
    required this.messages,
    required this.sizeOfChat,
    required this.chatName,
    required this.msgsPerMember,
    required this.indexesPerMember,
    this.imagesPaths,
  });

  final List<String> members;
  final List<MessageContent> messages;
  final int sizeOfChat;
  final String chatName;
  final Map<String, int> msgsPerMember;
  final Map<String, List<int>> indexesPerMember;
  final List<String>? imagesPaths;

  Map<String, dynamic> toJson() => {
    'chatName': chatName,
    'sizeOfChat': sizeOfChat,
    'names': members,
    'msgContents': _listOfMessageContentsToJson(messages),
    'msgsPerPerson': msgsPerMember,
    'indexesPerPerson': indexesPerMember,
    'imagesPaths': imagesPaths,
  };

  /// We should parse also all the [MessageContent] toJson
  static List<Map<String, dynamic>> _listOfMessageContentsToJson(
      List<MessageContent> messages) {
    List<Map<String, dynamic>> messagesParsed = [];

    for (int i = 0; i < messages.length; i++) {
      messagesParsed.add(messages[i].toJson());
    }

    return messagesParsed;
  }

  static ChatContent fromJson(Map<String, dynamic> chatMap) {
    List<MessageContent> msgs = [];

    for (var item in chatMap['msgContents']) {
      msgs.add(MessageContent.fromJson((item)));
    }

    return ChatContent(
      chatName: chatMap['chatName'],
      sizeOfChat: chatMap['sizeOfChat'],
      members: List<String>.from(chatMap['names']),
      messages: msgs,
      msgsPerMember: Map<String, int>.from(chatMap['msgsPerPerson']),
      imagesPaths: chatMap['imagesPaths'] != null
          ? List<String>.from(chatMap['imagesPaths'])
          : null,
      indexesPerMember: chatMap['indexesPerPerson'] == null
          ? {}
          : _toIndexesPerMember(
          Map<String, dynamic>.from(chatMap['indexesPerPerson'])),
    );
  }

  static Map<String, List<int>> _toIndexesPerMember(Map<String, dynamic> lst) {
    Map<String, List<int>> indexesPerMember = {};
    for (var key in lst.keys) {
      indexesPerMember[key] = List<int>.from(lst[key]);
    }
    return indexesPerMember;
  }

  Future<Image?> getImage(String imageName) async {
    if (imagesPaths == null) {
      return null;
    }
    /// The file name is like this: "IMG-20220609-WA0012.jpg (file attached)"
    imageName = imageName.split(' ').first;
    String? path = imagesPaths
        ?.firstWhereOrNull((String path) => path.contains(imageName));
    if (path == null) {
      return null;
    }
    return await getImageByPath(path);
  }

  static Future<Image?> getImageByPath(String path) async {
    final bytes = Uint8List.fromList(await ReceiveWhatsappChat.methodChannel
        .invokeMethod("getImage", <String, dynamic>{"data": path}));
    final codec = await instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatContent &&
              runtimeType == other.runtimeType &&
              chatName == other.chatName &&
              sizeOfChat == other.sizeOfChat &&
              listEquals<String>(members, other.members) &&
              listEquals<MessageContent>(messages, other.messages) &&
              indexesPerMember == other.indexesPerMember &&
              msgsPerMember == other.msgsPerMember;

  @override
  String toString() {
    return 'ChatContent{names: $members, sizeOfChat: $sizeOfChat, chatName: $chatName, msgsPerPerson: $msgsPerMember, imagesPaths: $imagesPaths}';
  }

  @override
  int get hashCode => hashValues(chatName, sizeOfChat, members, messages,
      indexesPerMember, msgsPerMember, imagesPaths);
}
