import 'package:flutter_test/flutter_test.dart';
import 'package:receive_whatsapp_chat/utils/logger.dart';

void main() {
  test('shape masks letters and digits but keeps the format', () {
    expect(
      Logger.shape('[25/04/2022, 10:17:07] Dolev: Hi'),
      '[99/99/9999, 99:99:99] aaaaa: aa',
    );
    expect(
      Logger.shape('25.4.22, 10:17 - Maya: Hello'),
      '99.9.99, 99:99 - aaaa: aaaaa',
    );
  });

  test('shape truncates long lines', () {
    expect(Logger.shape('a' * 100, 10), '${'a' * 10}…');
  });
}
