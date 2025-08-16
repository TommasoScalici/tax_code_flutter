import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';

void main() {
  /// A group of tests for the [Birthplace] model.
  group('Birthplace', () {
    final birthplace = const Birthplace(name: 'Torino', state: 'TO');
    final birthplaceMap = {'name': 'Torino', 'state': 'TO'};

    /// Tests if a [Birthplace] instance is correctly created from a JSON map.
    test('fromJson should return a valid model', () {
      final model = Birthplace.fromJson(birthplaceMap);
      expect(model.name, birthplace.name);
      expect(model.state, birthplace.state);
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
      final birthplace1 = const Birthplace(name: 'Torino', state: 'TO');
      final birthplace2 = const Birthplace(name: 'Torino', state: 'TO');
      expect(birthplace1, equals(birthplace2));
    });

    test('should be equal when properties are the same and not equal when they are different', () {
      // Arrange
      final birthplace1 = const Birthplace(name: 'Torino', state: 'TO');
      final birthplace2 = const Birthplace(name: 'Torino', state: 'TO');
      final birthplace3 = const Birthplace(name: 'Milano', state: 'MI');

      // Assert
      expect(birthplace1, equals(birthplace2));
      expect(birthplace1, isNot(equals(birthplace3)));
    });
  });
}
