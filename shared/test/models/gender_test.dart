import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/gender.dart';

void main() {
  group('Gender Enum Tests', () {
    test('exposes correct codes', () {
      expect(Gender.male.code, 'M');
      expect(Gender.female.code, 'F');
      expect(Gender.male.isMale, isTrue);
      expect(Gender.male.isFemale, isFalse);
      expect(Gender.female.isFemale, isTrue);
      expect(Gender.female.isMale, isFalse);
    });

    test(
      'fromCode parses standard and full gender representations case-insensitively',
      () {
        expect(Gender.fromCode('M'), Gender.male);
        expect(Gender.fromCode('m'), Gender.male);
        expect(Gender.fromCode('MALE'), Gender.male);
        expect(Gender.fromCode('male'), Gender.male);

        expect(Gender.fromCode('F'), Gender.female);
        expect(Gender.fromCode('f'), Gender.female);
        expect(Gender.fromCode('FEMALE'), Gender.female);
        expect(Gender.fromCode('female'), Gender.female);

        expect(Gender.fromCode(null), isNull);
        expect(Gender.fromCode(''), isNull);
        expect(Gender.fromCode('other'), isNull);
      },
    );

    test('toString returns code', () {
      expect(Gender.male.toString(), 'M');
      expect(Gender.female.toString(), 'F');
    });
  });
}
