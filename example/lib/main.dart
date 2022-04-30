import 'dart:math';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp chat share Plugin Demo',
      theme: ThemeData(),
      home: const DemoApp(),
    );
  }
}

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends ReceiveWhatsappChat<DemoApp> {
  List<ChatContent> chats = [];

  @override
  void dispose() {
    disableShareReceiving();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Whatsapp Chat Export Plugin Demo'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Chats exported:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(
                height: 20,
              ),
              chats.isEmpty
                  ? const Text('Open WhatsApp to export chats')
                  : const SizedBox(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                        chats.length, (index) => buildShowChat(index)),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Open WhatsApp'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'com.whatsapp',
                      iosUrlScheme: 'whatsapp://app',
                      appStoreLink: 'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildShowChat(int index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name - ${chats[index].chatName}\n'),
                Text('Members - ${chats[index].members}\n'),
                Text('Size of the chat - ${chats[index].sizeOfChat}\n'),
                Text('Messages per member - ${chats[index].msgsPerMember}\n'),
                const Text('Three random messages:\n'),
                Column(
                  children: List.generate(
                      3,
                      (index2) => Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                                '\t${index2 + 1}. ${chats[index].messages[Random().nextInt(chats[index].sizeOfChat)]}\n'),
                          )),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      );

  @override
  void receiveChatContent(ChatContent chatContent) {
    chats.add(chatContent);
    setState(() {});
  }
}
