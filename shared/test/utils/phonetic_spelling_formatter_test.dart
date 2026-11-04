import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/phonetic_spelling_formatter.dart';

void main() {
  group('PhoneticSpellingFormatter', () {
    test('returns empty string for empty input', () {
      expect(PhoneticSpellingFormatter.format(''), isEmpty);
      expect(PhoneticSpellingFormatter.format('   '), isEmpty);
    });

    test('formatCharacter formats letters correctly', () {
      expect(PhoneticSpellingFormatter.formatCharacter('a'), 'A come Ancona');
      expect(PhoneticSpellingFormatter.formatCharacter('Z'), 'Z come Zara');
      expect(PhoneticSpellingFormatter.formatCharacter('h'), 'H come Hotel');
    });

    test('formatCharacter formats digits correctly', () {
      expect(PhoneticSpellingFormatter.formatCharacter('0'), 'zero');
      expect(PhoneticSpellingFormatter.formatCharacter('5'), 'cinque');
      expect(PhoneticSpellingFormatter.formatCharacter('9'), 'nove');
    });

    test('formatCharacter returns unknown symbols unchanged', () {
      expect(PhoneticSpellingFormatter.formatCharacter('-'), '-');
      expect(PhoneticSpellingFormatter.formatCharacter(''), '');
    });

    test('formats a standard 16-character Italian tax code', () {
      const taxCode = 'RSSMRA80A01H501U';
      final formatted = PhoneticSpellingFormatter.format(taxCode);

      const expected =
          'R come Roma, S come Sassari, S come Sassari, M come Milano, '
          'R come Roma, A come Ancona, otto, zero, A come Ancona, zero, uno, '
          'H come Hotel, cinque, zero, uno, U come Udine';

      expect(formatted, expected);
    });

    test('handles whitespace gracefully', () {
      const taxCode = ' RSS MRA 80A01 H501U ';
      final formatted = PhoneticSpellingFormatter.format(taxCode);

      const expected =
          'R come Roma, S come Sassari, S come Sassari, M come Milano, '
          'R come Roma, A come Ancona, otto, zero, A come Ancona, zero, uno, '
          'H come Hotel, cinque, zero, uno, U come Udine';

      expect(formatted, expected);
    });
  });
}
