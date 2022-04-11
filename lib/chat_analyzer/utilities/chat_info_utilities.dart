import 'package:receive_whatsapp_chat/chat_analyzer/languages/languages.dart';
import 'package:receive_whatsapp_chat/models/message_content.dart';

import 'fix_dates_utilities.dart';

class ChatInfoUtilities {
  //static final RegExp _regExp = RegExp(r"\d\d/\d\d/\d\d\d\d,\s+\d\d:\d\d\s+-");
  static final RegExp _regExp = RegExp(r"\d\d?[/|.]\d\d?[/|.]\d?\d?\d\d,\s+\d\d?:\d\d\s+-");


  /// chat info contains messages per member, members of the chat, messages, and size of the chat
  static Map<String, dynamic> getChatInfo(List<String> chat) {
    Map<String, dynamic> chatInfo = {};

    List<String> names = [];
    List<int> countNameMsgs = [];
    List<MessageContent> msgContents = [];

    for (int i = 1; i < chat.length; i++) {
      MessageContent msgContent = _getMsgContentFromStringLine(chat[i]);
      if (!names.contains(msgContent.senderId) && msgContent.senderId != null) {
        names.add(msgContent.senderId!);
        countNameMsgs.add(1);
        msgContents.add(msgContent);
      } else {
        if (msgContent.senderId != null) {
          countNameMsgs[names.indexOf(msgContent.senderId!)]++;
          msgContents.add(msgContent);
        }
      }
    }

    chatInfo['msgsPerPerson'] = {};

    names.remove(null);
    for (int i = 0; i < names.length; i++) {
      chatInfo['msgsPerPerson'][names[i]] = countNameMsgs[i];
    }

    chatInfo['names'] = names;
    chatInfo['sizeOfChat'] = msgContents.length;
    chatInfo['messages'] = msgContents;

    return chatInfo;
  }

  /// Receive a String line and return from it [MessageContent]
  static MessageContent _getMsgContentFromStringLine(String line) {
    MessageContent nullMessageContent =
        MessageContent(senderId: null, msg: null);

    if (line.split(' - ').length == 1) {
      return nullMessageContent;
    }

    String splitLineToTwo = line.split(_regExp).last;
    if (splitLineToTwo.split(': ').length == 1) {
      return nullMessageContent;
    }

    String senderId = splitLineToTwo.split(': ')[0];
    String msg = splitLineToTwo.split(': ').sublist(1).join(': ');

    if (Languages.hasMatchForAll(msg)) {
      return nullMessageContent;
    }

    return MessageContent(
      senderId: senderId,
      msg: msg,
      dateTime: _parseLineToDatetime(line),
    );
  }

  /// Receive a String line and return from it [DateTime], if it fails it returns null
  static DateTime? _parseLineToDatetime(String line) {
    if (line.split(' - ').length == 1) {
      return null;
    }

    String splitLineToTwo = line.split(' - ').first;

    List dateFromLine = splitLineToTwo.split(', ');

    if (dateFromLine.length == 1) {
      return null;
    }

    String? date;
    String? hour;
    try {
      date = FixDateUtilities.dateStringOrganization(dateFromLine[0]);
      hour = FixDateUtilities.hourStringOrganization(dateFromLine[1]);
    } catch (e) {
      return null;
    }

    DateTime datetime;
    try {
      datetime = DateTime.parse('$date $hour');
    } catch (e) {
      return null;
    }
    return datetime;
  }
}
