import 'message_content.dart';

/// Class for the whole settings of the chat
class ChatContent {
  ChatContent({
    required this.members,
    required this.messages,
    required this.sizeOfChat,
    required this.chatName,
    required this.msgsPerMember,
  });

  final List<String> members;
  final List<MessageContent> messages;
  final int sizeOfChat;
  final String chatName;
  final Map<String, int> msgsPerMember;

  Map<String, dynamic> toJson() => {
        'chatName': chatName,
        'sizeOfChat': sizeOfChat,
        'names': members,
        'msgContents': _listOfMessageContentsToJson(messages),
        'msgsPerPerson': msgsPerMember,
      };

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
    );
  }

  @override
  String toString() {
    return 'ChatContent{names: $members, sizeOfChat: $sizeOfChat, chatName: $chatName, msgsPerPerson: $msgsPerMember}';
  }
}
