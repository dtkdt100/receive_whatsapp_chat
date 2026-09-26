import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

/// Builds a small fake chat so the demo can be explored without WhatsApp.
ChatContent buildSampleChat() {
  final start = DateTime.now().subtract(const Duration(days: 2, hours: 3));
  final lines = <(String, String, int)>[
    ('Maya', 'Hey! Did you try the new plugin yet? 👀', 0),
    ('Daniel', 'Not yet, what does it do?', 2),
    ('Maya', 'You export a chat from WhatsApp and share it to your app', 3),
    ('Maya', 'It parses everything into a ChatContent object', 3),
    ('Noa', 'Members, messages, dates, stats per member...', 5),
    ('Daniel', 'Oh nice, so I get a List<MessageContent>?', 9),
    ('Maya', 'Exactly. Each one has senderId, msg and dateTime', 10),
    (
      'Noa',
      'I built a chat stats screen with it in like 10 minutes 😄',
      60 * 20,
    ),
    ('Daniel', 'Ok trying it now', 60 * 21),
    ('Daniel', 'Works on Android and iOS 🎉', 60 * 26),
    ('Maya', 'Told you!', 60 * 26 + 1),
  ];

  final messages = [
    for (final (sender, text, minutes) in lines)
      MessageContent(
        senderId: sender,
        msg: text,
        dateTime: start.add(Duration(minutes: minutes)),
      ),
  ];

  final members = <String>[];
  final indexesPerMember = <String, List<int>>{};
  for (var i = 0; i < messages.length; i++) {
    final sender = messages[i].senderId!;
    if (!members.contains(sender)) members.add(sender);
    indexesPerMember.putIfAbsent(sender, () => []).add(i);
  }

  return ChatContent(
    chatName: 'Sample group 🧪',
    members: members,
    messages: messages,
    sizeOfChat: messages.length,
    indexesPerMember: indexesPerMember,
    msgsPerMember: {
      for (final entry in indexesPerMember.entries)
        entry.key: entry.value.length,
    },
  );
}
