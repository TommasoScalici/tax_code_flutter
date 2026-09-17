import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/utils/birthplace_search_filter.dart';

void main() {
  group('BirthplaceSearchFilter', () {
    const roma = Birthplace(name: 'Roma', state: 'RM', code: 'H501');
    const milano = Birthplace(name: 'Milano', state: 'MI', code: 'F205');
    const bologna = Birthplace(name: 'Bologna', state: 'BO', code: 'A944');
    const forli = Birthplace(name: 'Forlì', state: 'FC', code: 'D704');
    const cantu = Birthplace(name: 'Cantù', state: 'CO', code: 'B639');
    const santAngelo = Birthplace(
      name: "Sant'Angelo a Cupolo",
      state: 'BN',
      code: 'I277',
    );

    final romaDistractors = [
      const Birthplace(name: 'Arcinazzo Romano', state: 'RM', code: 'A370'),
      const Birthplace(name: 'Bagnara di Romagna', state: 'RA', code: 'A551'),
      const Birthplace(name: 'Bagno di Romagna', state: 'FC', code: 'A565'),
      const Birthplace(name: 'Barbarano Romano', state: 'VT', code: 'A632'),
      const Birthplace(name: 'Bassano Romano', state: 'VT', code: 'A704'),
      const Birthplace(name: 'Campagnano di Roma', state: 'RM', code: 'B496'),
      const Birthplace(name: 'Carpineto Romano', state: 'RM', code: 'B828'),
      const Birthplace(name: 'Casalromano', state: 'MN', code: 'B911'),
      const Birthplace(name: 'Castel San Pietro Romano', state: 'RM', code: 'C266'),
      const Birthplace(name: 'Cervara di Roma', state: 'RM', code: 'C543'),
      const Birthplace(name: 'Cineto Romano', state: 'RM', code: 'C702'),
      const Birthplace(name: 'Civitella di Romagna', state: 'FC', code: 'C777'),
      const Birthplace(name: 'Fabrica di Roma', state: 'VT', code: 'D453'),
      const Birthplace(name: 'Fiano Romano', state: 'RM', code: 'D561'),
      const Birthplace(name: 'Genzano di Roma', state: 'RM', code: 'D972'),
      const Birthplace(name: 'Giuliano di Roma', state: 'FR', code: 'E057'),
      const Birthplace(name: 'Magliano Romano', state: 'RM', code: 'E813'),
      const Birthplace(name: 'Mazzano Romano', state: 'RM', code: 'F064'),
      const Birthplace(name: 'Monte Romano', state: 'VT', code: 'F603'),
      const Birthplace(name: 'Montorio Romano', state: 'RM', code: 'F687'),
      const Birthplace(name: 'Morciano di Romagna', state: 'RN', code: 'F715'),
      const Birthplace(name: 'Olevano Romano', state: 'RM', code: 'G022'),
      const Birthplace(name: 'Oriolo Romano', state: 'VT', code: 'G111'),
      const Birthplace(name: 'Ponzano Romano', state: 'RM', code: 'G875'),
      const Birthplace(name: 'Roccaromana', state: 'CE', code: 'H436'),
      roma,
      const Birthplace(name: 'Romana', state: 'SS', code: 'H505'),
      const Birthplace(name: 'Romano Canavese', state: 'TO', code: 'H511'),
    ];

    group('damerauLevenshteinDistance', () {
      test('identifies exact strings as distance 0', () {
        expect(BirthplaceSearchFilter.damerauLevenshteinDistance('roma', 'roma'), 0);
      });

      test('identifies single insertion/deletion', () {
        expect(BirthplaceSearchFilter.damerauLevenshteinDistance('roma', 'romma'), 1);
        expect(BirthplaceSearchFilter.damerauLevenshteinDistance('milano', 'milan'), 1);
      });

      test('identifies transposition of adjacent characters', () {
        expect(BirthplaceSearchFilter.damerauLevenshteinDistance('milano', 'milnao'), 1);
      });

      test('identifies single substitution', () {
        expect(BirthplaceSearchFilter.damerauLevenshteinDistance('roma', 'toma'), 1);
      });
    });

    group('search & ranking', () {
      test('places exact match "Roma" at index 0 despite numerous alphabetical distractors', () {
        final results = BirthplaceSearchFilter.search(romaDistractors, 'roma');

        expect(results, isNotEmpty);
        expect(results.first, equals(roma));
      });

      test('places shorter prefix match before longer prefix matches', () {
        final results = BirthplaceSearchFilter.search(romaDistractors, 'roma');

        // Roma (len 4) -> Romana (len 6) -> Romano Canavese
        expect(results[0], equals(roma));
        expect(results[1].name, equals('Romana'));
        expect(results[2].name, equals('Romano Canavese'));
      });

      test('returns empty list for queries shorter than 2 characters', () {
        expect(BirthplaceSearchFilter.search(romaDistractors, ''), isEmpty);
        expect(BirthplaceSearchFilter.search(romaDistractors, 'r'), isEmpty);
        expect(BirthplaceSearchFilter.search(romaDistractors, ' '), isEmpty);
      });

      test('handles case-insensitivity seamlessly', () {
        final resultsUpper = BirthplaceSearchFilter.search(romaDistractors, 'ROMA');
        final resultsLower = BirthplaceSearchFilter.search(romaDistractors, 'roma');

        expect(resultsUpper.first, equals(roma));
        expect(resultsLower.first, equals(roma));
      });

      test('normalizes diacritics / accents', () {
        final places = [forli, cantu, milano];

        final forliResult = BirthplaceSearchFilter.search(places, 'forli');
        expect(forliResult.first, equals(forli));

        final cantuResult = BirthplaceSearchFilter.search(places, 'cantu');
        expect(cantuResult.first, equals(cantu));
      });

      test('handles apostrophes and spaces in query and municipality name', () {
        final places = [santAngelo, milano];

        final res1 = BirthplaceSearchFilter.search(places, 'sant angelo');
        expect(res1.first, equals(santAngelo));

        final res2 = BirthplaceSearchFilter.search(places, "sant'angelo");
        expect(res2.first, equals(santAngelo));
      });

      test('supports compound search with name and province', () {
        final results1 = BirthplaceSearchFilter.search(romaDistractors, 'roma rm');
        expect(results1.first, equals(roma));

        final results2 = BirthplaceSearchFilter.search(romaDistractors, 'roma (rm)');
        expect(results2.first, equals(roma));
      });

      test('supports province-only search', () {
        final results = BirthplaceSearchFilter.search(romaDistractors, 'rm');
        expect(results, isNotEmpty);
        expect(results.every((b) => b.state == 'RM' || b.name.toLowerCase().contains('rm')), isTrue);
      });
    });

    group('fuzzy matching', () {
      test('suggests Roma when user types "romma" (insertion typo)', () {
        final results = BirthplaceSearchFilter.search(romaDistractors, 'romma');
        expect(results, isNotEmpty);
        expect(results.first, equals(roma));
      });

      test('suggests Milano when user types "milnao" (transposition typo)', () {
        final places = [milano, bologna, roma];
        final results = BirthplaceSearchFilter.search(places, 'milnao');
        expect(results, isNotEmpty);
        expect(results.first, equals(milano));
      });

      test('suggests Bologna when user types "bolongna" (insertion typo)', () {
        final places = [milano, bologna, roma];
        final results = BirthplaceSearchFilter.search(places, 'bolongna');
        expect(results, isNotEmpty);
        expect(results.first, equals(bologna));
      });
    });
  });
}
