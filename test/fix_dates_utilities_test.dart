import 'package:flutter_test/flutter_test.dart';
import 'package:receive_whatsapp_chat/chat_analyzer/utilities/fix_dates_utilities.dart';

void main() {
  group('dateStringOrganization', () {
    test('Android dates', () {
      expect(
          FixDateUtilities.dateStringOrganization('25/04/2022'), '2022-04-25');
      expect(FixDateUtilities.dateStringOrganization('5.4.22'), '2022-04-05');
    });

    test('iOS dates', () {
      expect(
          FixDateUtilities.dateStringOrganization('[25/04/2022'), '2022-04-25');
    });

    test('iOS attachment lines start with a left-to-right mark', () {
      expect(FixDateUtilities.dateStringOrganization('‎[26/09/2026'),
          '2026-09-26');
    });
  });

  group('hourStringOrganization', () {
    test('24 hour', () {
      expect(FixDateUtilities.hourStringOrganization('10:17'), '10:17:00');
      expect(FixDateUtilities.hourStringOrganization('9:05:07'), '09:05:00');
    });

    test('12 hour', () {
      expect(FixDateUtilities.hourStringOrganization('1:05 PM'), '13:05:00');
    });
  });
}
