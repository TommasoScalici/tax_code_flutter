import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';

void main() {
  /// A group of tests for the [Birthplace] model.
  group('Birthplace', () {
    final birthplace = Birthplace(name: 'Torino', state: 'TO');
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
  });
}
