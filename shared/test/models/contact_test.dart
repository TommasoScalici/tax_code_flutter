import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

void main() {
  /// Tests for the Contact model
  group('Contact Model', () {
    final birthDate = DateTime(1990, 1, 15);
    const birthplace = Birthplace(name: 'Roma', state: 'RM', code: 'H501');
    final contact = Contact(
      id: '12345',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA90A15H501A',
      birthPlace: birthplace,
      birthDate: birthDate,
      listIndex: 0,
    );

    /// Grouping tests for serialization
    group('Serialization', () {
      final contactMap = {
        'id': '12345',
        'firstName': 'Mario',
        'lastName': 'Rossi',
        'gender': 'M',
        'taxCode': 'RSSMRA90A15H501A',
        'birthPlace': {'name': 'Roma', 'state': 'RM', 'code': 'H501'},
        'birthDate': Timestamp.fromDate(birthDate),
        'listIndex': 0,
        'updatedAt': null,
      };

      /// Tests for converting JSON to the model
      test('fromJson should return a valid model', () {
        final model = Contact.fromJson(contactMap);
        expect(model, equals(contact));
      });

      /// Tests for converting the model to JSON
      test('toJson should return a valid json map', () {
        final json = contact.toJson();
        expect(json, equals(contactMap));
        expect(json['birthDate'], isA<Timestamp>());
      });
    });

    /// Grouping tests for model logic and extensions
    group('Model Logic', () {
      /// Tests for the create factory constructor
      test('create factory should create a contact with default values', () {
        final emptyContact = Contact.create();

        expect(emptyContact.id, isNotEmpty);
        expect(emptyContact.firstName, '');
        expect(emptyContact.lastName, '');
        expect(emptyContact.birthDate, DateTime(1970));
        expect(emptyContact.listIndex, 0);
        expect(emptyContact.updatedAt, isNotNull);
      });

      /// Tests for the copyWith method
      test('copyWith should create a copy with updated values', () {
        final updatedContact = contact.copyWith(
          firstName: 'Luigi',
          listIndex: 1,
        );

        expect(updatedContact.id, contact.id);
        expect(updatedContact.firstName, 'Luigi');
        expect(updatedContact.lastName, contact.lastName);
        expect(updatedContact.listIndex, 1);
      });

      /// Tests for the toString method
      test('toString should return a formatted string', () {
        final stringRepresentation = contact.toString();
        // La formattazione yMd di default in 'en' è M/d/yyyy
        const expectedString = 'Mario Rossi (M) - 1/15/1990 - Roma (RM)';

        expect(stringRepresentation, equals(expectedString));
      });

      /// Tests for the equality operator
      test('equality should be based on value fields', () {
        final sameContact = contact.copyWith();
        final contactWithDifferentName = contact.copyWith(firstName: 'Giuseppe');
        final contactWithDifferentTaxCode = contact.copyWith(taxCode: 'RSSGPP90A15H501A');
        final contactWithDifferentId = contact.copyWith(id: '67890');

        expect(contact, equals(sameContact));
        expect(contact, isNot(equals(contactWithDifferentName)));
        expect(contact, isNot(equals(contactWithDifferentTaxCode)));
        expect(contact, isNot(equals(contactWithDifferentId)));
      });

      /// Tests for entity identity comparison
      test('isSameEntity should be based on id only', () {
        final contactWithSameIdDifferentFields = contact.copyWith(
          firstName: 'Giuseppe',
          taxCode: 'DIFFCODE',
        );
        final contactWithDifferentId = contact.copyWith(id: '67890');

        expect(contact.isSameEntity(contactWithSameIdDifferentFields), isTrue);
        expect(contact.isSameEntity(contactWithDifferentId), isFalse);
      });

      /// Tests for typed gender getter
      test('genderEnum should correctly parse and expose typed Gender', () {
        expect(contact.genderEnum, Gender.male);
        expect(contact.copyWith(gender: 'F').genderEnum, Gender.female);
        expect(contact.copyWith(gender: 'female').genderEnum, Gender.female);
        expect(contact.copyWith(gender: 'invalid').genderEnum, Gender.male);
      });
    });
  });
}
