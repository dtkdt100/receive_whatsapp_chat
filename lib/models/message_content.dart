import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../chat_analyzer/utilities/fix_dates_utilities.dart';

/// Each message in the chat class
class MessageContent {
  MessageContent({required this.senderId, required this.msg, this.dateTime});

  final String? senderId;
  final String? msg;
  final DateTime? dateTime;

  Map<String, dynamic> toJson() =>
      {
        'senderId': senderId,
        'msg': msg,
        'dateTime': dateTime.toString(),
      };

  @override
  String toString() {
    return 'MessageContent{senderId: $senderId, msg: $msg, dateTime: $dateTime}';
  }

  bool isImage() {
    RegExp pattern = RegExp(r'IMG-\d\d\d\d\d\d\d\d-WA\d\d\d\d\d?\d?[.]jpg');
    if (dateTime != null && msg != null) {
      String dateTimeString = dateTime!.year.toString() +
          FixDateUtilities.fixMonthOrDayTo01(dateTime!.month.toString()) +
          FixDateUtilities.fixMonthOrDayTo01(dateTime!.day.toString());
      return msg!.startsWith("IMG-$dateTimeString-WA") && msg!.startsWith(pattern);
    } else if (msg != null) {
      return msg!.startsWith(pattern);
    }
    return false;
  }

  static MessageContent fromJson(Map<String, dynamic> messageMap) {
    try {
      return MessageContent(
          senderId: messageMap['senderId'],
          msg: messageMap['msg'],
          dateTime: DateTime.parse(messageMap['dateTime']));
    } catch (e) {
      return MessageContent(
        senderId: messageMap['senderId'],
        msg: messageMap['msg'],
      );
    }
  }

  static List<MessageContent> fromJsonList(
      List<Map<String, dynamic>> messagesMap) {
    List<MessageContent> msgsParsed = [];

    for (var item in messagesMap) {
      msgsParsed.add(fromJson(item));
    }

    return msgsParsed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageContent &&
              runtimeType == other.runtimeType &&
              senderId == other.senderId &&
              msg == other.msg &&
              dateTime == other.dateTime;

  @override
  int get hashCode => hashValues(senderId, msg, dateTime);
}
