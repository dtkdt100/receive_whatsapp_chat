import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

import 'chat_page.dart';
import 'format.dart';
import 'sample_chat.dart';

void main() {
  runApp(const MyApp());
}

const whatsAppGreen = Color(0xFF25D366);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme() {
    final scheme = ColorScheme.fromSeed(seedColor: whatsAppGreen);
    return ThemeData(
      colorScheme: scheme,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receive WhatsApp Chat',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

/// Extending [ReceiveWhatsappChat] is all it takes: every chat shared from
/// WhatsApp arrives in [receiveChatContent] already parsed.
class HomePageState extends ReceiveWhatsappChat<HomePage> {
  final List<ChatContent> chats = [];

  @override
  void receiveChatContent(ChatContent chatContent) {
    _addChat(chatContent);
  }

  void _addChat(ChatContent chat) {
    setState(() => chats.insert(0, chat));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Received "${chat.chatName}" · ${chat.sizeOfChat} messages',
          ),
          action: SnackBarAction(label: 'View', onPressed: () => _open(chat)),
        ),
      );
  }

  void _open(ChatContent chat) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatPage(chat: chat)));
  }

  Future<void> _openWhatsApp() => LaunchApp.openApp(
    androidPackageName: 'com.whatsapp',
    iosUrlScheme: 'whatsapp://app',
    appStoreLink:
        'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
  );

  @override
  void dispose() {
    disableShareReceiving();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('WhatsApp Chat Receiver'),
            actions: [
              if (chats.isNotEmpty)
                IconButton(
                  tooltip: 'How it works',
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: HowItWorks(),
                    ),
                  ),
                ),
            ],
          ),
          if (chats.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                onOpenWhatsApp: _openWhatsApp,
                onTrySample: () => _addChat(buildSampleChat()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList.separated(
                itemCount: chats.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Text(
                        'Received chats · tap to explore',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final chat = chats[i - 1];
                  return Dismissible(
                    key: ObjectKey(chat),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => setState(() => chats.remove(chat)),
                    child: ChatCard(chat: chat, onTap: () => _open(chat)),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: chats.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.ios_share),
              label: const Text('Export another chat'),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onOpenWhatsApp, required this.onTrySample});

  final VoidCallback onOpenWhatsApp;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share any chat from WhatsApp to this app and see it parsed '
            'into members, messages and stats.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const HowItWorks(),
          const Spacer(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onOpenWhatsApp,
            icon: const Icon(Icons.chat),
            label: const Text('Open WhatsApp'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: whatsAppGreen,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onTrySample,
            icon: const Icon(Icons.science_outlined),
            label: const Text('No WhatsApp handy? Try a sample chat'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ],
      ),
    );
  }
}

/// The export steps, shown on the empty screen and in the help sheet.
class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = Platform.isIOS
        ? const [
            'Open a chat in WhatsApp',
            'Tap the contact or group name at the top',
            'Scroll down and tap "Export Chat"',
            'Choose "Without Media", then pick this app',
          ]
        : const [
            'Open a chat in WhatsApp',
            'Tap ⋮  →  More  →  Export chat',
            'Choose "Without media"',
            'Pick this app in the share sheet',
          ];

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How it works', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final (i, text) in steps.indexed)
              _Step(number: i + 1, text: text, isLast: i == steps.length - 1),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, required this.isLast});

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text(
                  '$number',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: scheme.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 20),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({super.key, required this.chat, required this.onTap});

  final ChatContent chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dates = chat.messages
        .map((m) => m.dateTime)
        .whereType<DateTime>()
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  initials(chat.chatName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.chatName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chat.members.length} members · '
                      '${chat.sizeOfChat} messages',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${formatDate(dates.first)} – ${formatDate(dates.last)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
