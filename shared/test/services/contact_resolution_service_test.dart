import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/contact_resolution_service.dart';

void main() {
  group('ContactResolutionService', () {
    const resolver = ContactResolutionService();
    const birthplace = Birthplace(name: 'Roma', state: 'RM', code: 'H501');

    final contactMe = Contact(
      id: 'id-me',
      firstName: 'Tommaso',
      lastName: 'Scalici',
      gender: 'M',
      taxCode: 'SCLTMS91A01H501X',
      birthPlace: birthplace,
      birthDate: DateTime(1991),
      listIndex: 0,
      isMe: true,
    );

    final contactMario = Contact(
      id: 'id-mario',
      firstName: 'Mario Giuseppe',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01H501Y',
      birthPlace: birthplace,
      birthDate: DateTime(1980),
      listIndex: 1,
    );

    final contactLuigi = Contact(
      id: 'id-luigi',
      firstName: 'Luigi',
      lastName: 'Verdi',
      gender: 'M',
      taxCode: 'VRDLGU85B02H501Z',
      birthPlace: birthplace,
      birthDate: DateTime(1985, 2, 2),
      listIndex: 2,
    );

    group('resolvePrimaryContact (3-level strategy)', () {
      test('returns null when contacts list is empty', () {
        final result = resolver.resolvePrimaryContact(
          [],
          userDisplayName: 'Tommaso Scalici',
        );
        expect(result, isNull);
      });

      test(
        'Level 1: returns contact marked with isMe == true regardless of other contacts or display name',
        () {
          final result = resolver.resolvePrimaryContact([
            contactMario,
            contactMe,
            contactLuigi,
          ], userDisplayName: 'Mario Rossi');
          expect(result, equals(contactMe));
        },
      );

      test('Level 2: matches exact userDisplayName when no isMe is set', () {
        final result = resolver.resolvePrimaryContact([
          contactLuigi,
          contactMario,
        ], userDisplayName: 'Luigi Verdi');
        expect(result, equals(contactLuigi));
      });

      test(
        'Level 2: matches partial token display name (e.g. Google "Mario Rossi" -> Contact "Mario Giuseppe Rossi")',
        () {
          final result = resolver.resolvePrimaryContact([
            contactLuigi,
            contactMario,
          ], userDisplayName: 'Mario Rossi');
          expect(result, equals(contactMario));
        },
      );

      test('Level 2: ignores case, accents, and extra whitespace', () {
        final result = resolver.resolvePrimaryContact([
          contactLuigi,
        ], userDisplayName: '  luìgi   vèrdi  ');
        expect(result, equals(contactLuigi));
      });

      test(
        'Level 3: falls back to the single contact if list has only 1 contact and no isMe',
        () {
          final result = resolver.resolvePrimaryContact([contactLuigi]);
          expect(result, equals(contactLuigi));
        },
      );

      test(
        'Level 3: falls back to single contact even with null or non-matching display name',
        () {
          final result = resolver.resolvePrimaryContact([
            contactLuigi,
          ], userDisplayName: 'Sconosciuto');
          expect(result, equals(contactLuigi));
        },
      );

      test(
        'returns null when multiple contacts exist with no isMe and no display name match',
        () {
          final result = resolver.resolvePrimaryContact([
            contactLuigi,
            contactMario,
          ], userDisplayName: 'Unknown User');
          expect(result, isNull);
        },
      );
    });

    group('resolveContact', () {
      test('returns null when contacts list is empty', () {
        expect(resolver.resolveContact([]), isNull);
      });

      test('resolves by exact contact ID', () {
        final result = resolver.resolveContact([
          contactMe,
          contactMario,
          contactLuigi,
        ], id: 'id-mario');
        expect(result, equals(contactMario));
      });

      test('falls back to primary contact when query is null or empty', () {
        final result = resolver.resolveContact([contactMe, contactMario]);
        expect(result, equals(contactMe));
      });

      test(
        'treats "me", "io", "mio", "il mio", "my" as primary contact query',
        () {
          for (final q in [
            'me',
            'io',
            'mio',
            'il mio',
            'my',
            'myself',
            ' ME ',
          ]) {
            final result = resolver.resolveContact([
              contactMe,
              contactMario,
            ], query: q);
            expect(result, equals(contactMe), reason: 'Failed for query "$q"');
          }
        },
      );

      test('resolves by exact tax code (case-insensitive)', () {
        final result = resolver.resolveContact([
          contactMe,
          contactMario,
        ], query: 'rssmra80a01h501y');
        expect(result, equals(contactMario));
      });

      test('resolves by contact name substring', () {
        final result = resolver.resolveContact([
          contactMe,
          contactMario,
          contactLuigi,
        ], query: 'Verdi');
        expect(result, equals(contactLuigi));
      });

      test('prioritizes isMe contact when multiple contacts match query', () {
        final anotherMario = contactMario.copyWith(
          id: 'another-mario',
          taxCode: 'RSSMRA99A01H501K',
          isMe: true,
        );
        final result = resolver.resolveContact([
          contactMario,
          anotherMario,
        ], query: 'Mario');
        expect(result, equals(anotherMario));
      });

      test('returns null when query has no matches', () {
        final result = resolver.resolveContact([
          contactMe,
          contactMario,
        ], query: 'NonEsiste');
        expect(result, isNull);
      });
    });
  });
}
