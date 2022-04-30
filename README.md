# receive_whatsapp_chat

A flutter plugin that enables flutter apps to receive chats from Whatsapp.

Note: the pulgin is currently Android only.

![alt text](https://github.com/dtkdt100/receive_whatsapp_chat/blob/main/screenshots/1.gif)

## Setup

Please add the following to `android/app/main/java/.../MainActivity.java`.

```java
import android.os.Bundle;

import io.flutter.plugins.GeneratedPluginRegistrant;

import com.whatsapp.receive_whatsapp_chat.FlutterShareReceiverActivity;

public class MainActivity extends FlutterShareReceiverActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
    }
}
```

## Usage

You can import the package with:

```dart
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';
```

You need to create a class that extends the class `ReceiveWhatsappChat`.

```dart
class DemoAppState extends ReceiveWhatsappChat<DemoApp>
```

It will make you implement a function that receive `Chat content` class every time a chat is
exported from WhatsApp.
`Chat content` contains chat members, chat name, messages per member, size of the chat and all of
its messages.

```dart
@override
void receiveChatContent(ChatContent chatContent) {
  // TODO: implement receiveChatContent
}
```

Note: `enableShareReceiving()` is called automatically when the plugin is initialized, so remember
to call `disableShareReceiving()` when you don't want to receive chats anymore or close the app.

Note: when you export a chat from WhatsApp, it is best to be in English.

## Full Example

`main.dart`

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp chat share Plugin Demo',
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
  static const MethodChannel _methodChannel =
  MethodChannel('com.whatsapp.chat/openwhatsapp');
  List<ChatContent> chats = [];

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
                  onPressed: () {
                    _methodChannel.invokeMethod("openwhatsapp");
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildShowChat(int index) =>
      Column(
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
                          (index2) =>
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                                '\t${index2 + 1}. ${chats[index].messages[Random().nextInt(
                                    chats[index].sizeOfChat)]}\n'),
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
```
