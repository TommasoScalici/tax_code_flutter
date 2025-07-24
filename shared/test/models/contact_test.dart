import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

void main() {
  /// Defines a test group for the [Contact] model.
  group('Contact', () {
    final birthDate = DateTime(1990, 1, 15);
    final contactMap = {
      'id': '12345',
      'firstName': 'Mario',
      'lastName': 'Rossi',
      'gender': 'M',
      'taxCode': 'RSSMRA90A15H501A',
      'birthPlace': {'name': 'Roma', 'state': 'RM'},
      'birthDate': birthDate.toIso8601String(),
      'listIndex': 0,
    };

    /// Tests that a [Contact] instance can be correctly created from a JSON map.
    test('fromJson should return a valid model', () {
      final contact = Contact.fromJson(contactMap);

      expect(contact.id, '12345');
      expect(contact.firstName, 'Mario');
      expect(contact.lastName, 'Rossi');
      expect(contact.taxCode, 'RSSMRA90A15H501A');
      expect(contact.birthDate, birthDate);
      expect(contact.birthPlace.name, 'Roma');
    });

    /// Tests that a [Contact] instance can be correctly converted to a JSON map.
    test('toJson should return a valid json map', () {
      final contact = Contact(
        id: '12345',
        firstName: 'Mario',
        lastName: 'Rossi',
        gender: 'M',
        taxCode: 'RSSMRA90A15H501A',
        birthPlace: Birthplace(name: 'Roma', state: 'RM'),
        birthDate: birthDate,
        listIndex: 0,
      );

      final json = contact.toJson();

      expect(json, equals(contactMap));
    });
  });
}
