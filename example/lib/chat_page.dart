import 'package:flutter/material.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

import 'format.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.chat});

  final ChatContent chat;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(chat.chatName, overflow: TextOverflow.ellipsis),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.insights), text: 'Overview'),
              Tab(icon: Icon(Icons.forum_outlined), text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(chat: chat),
            _MessagesTab(chat: chat),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.chat});

  final ChatContent chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dates = chat.messages
        .map((m) => m.dateTime)
        .whereType<DateTime>()
        .toList();
    final activeDays = {
      for (final d in dates) DateTime(d.year, d.month, d.day),
    }.length;
    final ranking = chat.msgsPerMember.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = ranking.isEmpty ? 1 : ranking.first.value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _StatTile(
              icon: Icons.chat_bubble_outline,
              value: '${chat.sizeOfChat}',
              label: 'Messages',
            ),
            const SizedBox(width: 12),
            _StatTile(
              icon: Icons.group_outlined,
              value: '${chat.members.length}',
              label: 'Members',
            ),
            const SizedBox(width: 12),
            _StatTile(
              icon: Icons.calendar_today_outlined,
              value: '$activeDays',
              label: 'Active days',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Who talks the most',
          child: Column(
            children: [
              for (final (i, entry) in ranking.indexed)
                _MemberBar(
                  rank: i + 1,
                  name: entry.key,
                  count: entry.value,
                  fraction: entry.value / maxCount,
                  share: chat.sizeOfChat == 0
                      ? 0
                      : entry.value / chat.sizeOfChat,
                ),
            ],
          ),
        ),
        if (dates.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'Timeline',
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.first_page,
                  label: 'First message',
                  value: formatDateTime(dates.first),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.last_page,
                  label: 'Last message',
                  value: formatDateTime(dates.last),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _DeveloperCard(chat: chat),
        const SizedBox(height: 16),
        Text(
          'Tip: switch to the Messages tab to see every parsed message.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.onPrimaryContainer),
            const SizedBox(height: 12),
            FittedBox(
              child: Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MemberBar extends StatelessWidget {
  const _MemberBar({
    required this.rank,
    required this.name,
    required this.count,
    required this.fraction,
    required this.share,
  });

  final int rank;
  final String name;
  final int count;
  final double fraction;
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = memberColor(name, theme.brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: rank == 1 ? FontWeight.w600 : null,
                  ),
                ),
              ),
              Text(
                '$count  ·  ${(share * 100).round()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shows the raw [ChatContent] fields, so developers can see what they get.
class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.chat});

  final ChatContent chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = chat.messages.isEmpty ? null : chat.messages.first;
    final fields = <(String, String)>[
      ('chatName', '"${chat.chatName}"'),
      ('members', '${chat.members}'),
      ('sizeOfChat', '${chat.sizeOfChat}'),
      ('msgsPerMember', '${chat.msgsPerMember}'),
      if (first != null) ...[
        ('messages[0].senderId', '"${first.senderId}"'),
        ('messages[0].msg', '"${first.msg}"'),
        ('messages[0].dateTime', '${first.dateTime}'),
      ],
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.code, color: scheme.primary),
          title: const Text('Developer view'),
          subtitle: const Text('What your app receives as ChatContent'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                  children: [
                    for (final (name, value) in fields) ...[
                      TextSpan(
                        text: 'chat.$name',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' = '),
                      TextSpan(text: '$value\n'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.chat});

  final ChatContent chat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final messages = chat.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('This chat has no messages'));
    }
    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          final msg = messages[i];
          final prev = i == 0 ? null : messages[i - 1];
          final newDay =
              msg.dateTime != null &&
              (prev?.dateTime == null ||
                  !isSameDay(prev!.dateTime!, msg.dateTime!));
          final sameSender = !newDay && prev?.senderId == msg.senderId;
          return Column(
            children: [
              if (newDay) _DayChip(date: msg.dateTime!),
              _Bubble(message: msg, showSender: !sameSender),
            ],
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            formatDate(date),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.showSender});

  final MessageContent message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sender = message.senderId ?? 'Unknown';
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          margin: EdgeInsets.only(top: showSender ? 8 : 2),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(showSender ? 4 : 16),
              topRight: const Radius.circular(16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSender)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    sender,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: memberColor(sender, theme.brightness),
                    ),
                  ),
                ),
              Text(message.msg ?? '', style: theme.textTheme.bodyLarge),
              if (message.dateTime != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formatTime(message.dateTime!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
