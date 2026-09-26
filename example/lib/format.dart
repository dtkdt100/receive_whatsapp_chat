import 'package:flutter/material.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String initials(String name) {
  final parts = name
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '#';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
}

/// Stable, readable color per chat member (like WhatsApp group name colors).
Color memberColor(String name, Brightness brightness) {
  const light = [
    Color(0xFF1E88E5), Color(0xFFD81B60), Color(0xFF8E24AA), //
    Color(0xFFF4511E), Color(0xFF00897B), Color(0xFF6D4C41),
    Color(0xFF3949AB), Color(0xFFC0CA33),
  ];
  const dark = [
    Color(0xFF64B5F6), Color(0xFFF06292), Color(0xFFBA68C8), //
    Color(0xFFFF8A65), Color(0xFF4DB6AC), Color(0xFFA1887F),
    Color(0xFF7986CB), Color(0xFFDCE775),
  ];
  final palette = brightness == Brightness.dark ? dark : light;
  final hash = name.codeUnits.fold<int>(0, (h, c) => (h * 31 + c) & 0x7fffffff);
  return palette[hash % palette.length];
}
