import 'message_content.dart';

/// Class for the whole settings of the chat
/// [chatName] - name of the chat
/// [members] - list of members of the chat
/// [messages] - list of [MessageContent] in the chat
/// [sizeOfChat] - size of the chat
/// [msgsPerMember] - number of messages per member
/// [indexesPerMember] - list of indexes of messages per member
class ChatContent {
  ChatContent({
    required this.members,
    required this.messages,
    required this.sizeOfChat,
    required this.chatName,
    required this.msgsPerMember,
    required this.indexesPerMember,
  });

  final List<String> members;
  final List<MessageContent> messages;
  final int sizeOfChat;
  final String chatName;
  final Map<String, int> msgsPerMember;
  final Map<String, List<int>> indexesPerMember;

  Map<String, dynamic> toJson() => {
        'chatName': chatName,
        'sizeOfChat': sizeOfChat,
        'names': members,
        'msgContents': _listOfMessageContentsToJson(messages),
        'msgsPerPerson': msgsPerMember,
        'indexesPerPerson': indexesPerMember,
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
      indexesPerMember: chatMap['indexesPerPerson'] == null ? {} : _toIndexesPerMember(Map<String, dynamic>.from(chatMap['indexesPerPerson'])),
    );
  }

  static Map<String, List<int>> _toIndexesPerMember(Map<String, dynamic> lst) {
    Map<String, List<int>> indexesPerMember = {};
    for (var key in lst.keys) {
      indexesPerMember[key] = List<int>.from(lst[key]);
    }
    return indexesPerMember;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatContent &&
          runtimeType == other.runtimeType &&
          chatName == other.chatName &&
          sizeOfChat == other.sizeOfChat &&
          members == other.members &&
          messages == other.messages &&
          indexesPerMember == other.indexesPerMember &&
          msgsPerMember == other.msgsPerMember;

  @override
  String toString() {
    return 'ChatContent{names: $members, sizeOfChat: $sizeOfChat, chatName: $chatName, msgsPerPerson: $msgsPerMember}';
  }


}
