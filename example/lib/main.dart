import 'dart:math';
import 'dart:ui' as ui;
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
      title: 'Receive WhatsApp Chat Plugin Demo',
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
          title: const Text('WhatsApp Chat Export Plugin Demo'),
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'com.whatsapp',
                      iosUrlScheme: 'whatsapp://app',
                      appStoreLink:
                          'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
                    );
                  },
                  child: const Text('Open WhatsApp'),
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
                  children: List.generate(3, (index2) {
                    MessageContent randomMessage = chats[index].messages[
                        Random().nextInt(chats[index].messages.length)];
                    return Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\t${index2 + 1}. $randomMessage\n'),
                          randomMessage.isImage()
                              ? buildFutureImageBuilder(
                                  chats[index].getImage(randomMessage.msg!))
                              : const SizedBox()
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      );

  Widget buildFutureImageBuilder(Future<ui.Image?> img) => FutureBuilder(
        future: img,
        builder: (BuildContext context, AsyncSnapshot<ui.Image?> image) {
          if (image.hasData && image.data != null) {
            return RawImage(
              image: image.data,
              scale: 4.5,
            ); // image is ready
          } else {
            return Container(); // placeholder
          }
        },
      );

  @override
  void receiveChatContent(ChatContent chatContent) {
    chats.add(chatContent);
    setState(() {});
  }
}
