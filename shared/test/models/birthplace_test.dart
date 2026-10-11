import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';

void main() {
  /// A group of tests for the [Birthplace] model.
  group('Birthplace', () {
    const birthplace = Birthplace(name: 'Torino', state: 'TO', code: 'L219');
    final birthplaceMap = {'name': 'Torino', 'state': 'TO', 'code': 'L219'};

    /// Tests if a [Birthplace] instance is correctly created from a JSON map.
    test('fromJson should return a valid model', () {
      final model = Birthplace.fromJson(birthplaceMap);
      expect(model.name, birthplace.name);
      expect(model.state, birthplace.state);
      expect(model.code, birthplace.code);
    });

    /// Tests if a [Birthplace] instance is correctly converted to a JSON map.
    test('toJson should return a valid map', () {
      final json = birthplace.toJson();
      expect(json, equals(birthplaceMap));
    });

    /// Tests if the toString method returns a correctly formatted string.
    test('toString should return a correctly formatted string', () {
      final result = birthplace.toString();
      expect(result, 'Torino (TO)');
    });

    test('should be equal when properties are the same', () {
      const birthplace1 = Birthplace(name: 'Torino', state: 'TO', code: 'L219');
      const birthplace2 = Birthplace(name: 'Torino', state: 'TO', code: 'L219');
      expect(birthplace1, equals(birthplace2));
    });

    test(
      'should be equal when properties are the same and not equal when they are different',
      () {
        // Arrange
        const birthplace1 = Birthplace(
          name: 'Torino',
          state: 'TO',
          code: 'L219',
        );
        const birthplace2 = Birthplace(
          name: 'Torino',
          state: 'TO',
          code: 'L219',
        );
        const birthplace3 = Birthplace(
          name: 'Milano',
          state: 'MI',
          code: 'F205',
        );

        // Assert
        expect(birthplace1, equals(birthplace2));
        expect(birthplace1, isNot(equals(birthplace3)));
      },
    );

    test('fromJson should populate precomputed normalized fields', () {
      final model = Birthplace.fromJson(const {
        'name': "Sant'Angelo a Cupolo",
        'state': 'BN',
        'code': 'I277',
      });

      expect(model.normalizedName, 'sant angelo a cupolo');
      expect(model.normalizedState, 'bn');
      expect(model.normalizedFull, 'sant angelo a cupolo bn');
      expect(model.nameWords, ['sant', 'angelo', 'a', 'cupolo']);
    });

    test(
      'should lazily compute normalized fields when created with const constructor',
      () {
        const model = Birthplace(
          name: "Sant'Angelo a Cupolo",
          state: 'BN',
          code: 'I277',
        );

        expect(model.normalizedName, 'sant angelo a cupolo');
        expect(model.normalizedState, 'bn');
        expect(model.normalizedFull, 'sant angelo a cupolo bn');
        expect(model.nameWords, ['sant', 'angelo', 'a', 'cupolo']);
      },
    );

    test(
      'withPrecomputedNormalizedData should return instance with precomputed fields',
      () {
        const original = Birthplace(name: 'Forlì', state: 'FC', code: 'D704');
        final precomputed = original.withPrecomputedNormalizedData();

        expect(precomputed.name, original.name);
        expect(precomputed.state, original.state);
        expect(precomputed.code, original.code);
        expect(precomputed.normalizedName, 'forli');
        expect(precomputed.normalizedState, 'fc');
        expect(precomputed.normalizedFull, 'forli fc');
        expect(precomputed.nameWords, ['forli']);
      },
    );
  });
}
