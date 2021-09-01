import 'package:receive_whatsapp_chat/chat_analyzer/utilities/chat_info_utilities.dart';
import 'package:receive_whatsapp_chat/models/chat_content.dart';

class ChatAnalyzer {
  /// Analyze [List<String>] to [ChatContent]
  static ChatContent analyze(List<String> chat) {
    String chatName = _getChatName(chat);
    Map<String, dynamic> chatInfo = ChatInfoUtilities.getChatInfo(chat);

    return ChatContent(
      members: chatInfo['names'],
      messages: chatInfo['messages'],
      sizeOfChat: chatInfo['sizeOfChat'],
      msgsPerMember: Map<String, int>.from(chatInfo['msgsPerPerson']),
      chatName: chatName,
    );
  }

  /// In case your phone is one English, The name of the chat will be like this:
  /// WhatsApp Chat with [Name of the chat] .txt
  /// The function spilt the name of the chat.
  static String _getChatName(List<String> chat) {
    return chat.first.split(".txt").first.split("WhatsApp Chat with ").last;
  }
}
