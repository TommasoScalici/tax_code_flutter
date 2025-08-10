import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

void main() {
  /// Tests for the Contact model
  group('Contact Model', () {
    final birthDate = DateTime(1990, 1, 15);
    final birthplace = Birthplace(name: 'Roma', state: 'RM');
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

    /// Grouping tests for JSON and Firestore serialization
    group('JSON Serialization', () {
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

      /// Tests for converting JSON to the model
      test('fromJson should return a valid model', () {
        final model = Contact.fromJson(contactMap);
        expect(model, equals(contact));
      });

      /// Tests for converting the model to JSON
      test('toJson should return a valid json map', () {
        final json = contact.toJson();
        expect(json, equals(contactMap));
      });
    });

    /// Grouping tests for Firestore serialization
    group('Firestore Serialization', () {
      test('toMap should return a map with a Timestamp', () {
        final map = contact.toMap();
        expect(map['birthDate'], isA<Timestamp>());
        expect((map['birthDate'] as Timestamp).toDate(), birthDate);
      });

      /// Tests for converting the model to a Firestore map
      test('fromMap should create a valid model from a map', () {
        final firestoreMap = contact.toMap();
        final model = Contact.fromMap(firestoreMap);
        expect(model, equals(contact));
      });
    });

    /// Grouping tests for model logic and extensions
    group('Model Logic', () {
      /// Tests for the empty factory constructor
      test('empty factory should create a contact with default values', () {
        final emptyContact = Contact.empty();

        expect(emptyContact.id, isNotEmpty);
        expect(emptyContact.firstName, '');
        expect(emptyContact.lastName, '');
        expect(emptyContact.listIndex, 0);
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

        expect(stringRepresentation, contains('Mario Rossi'));
        expect(stringRepresentation, contains('(M)'));
      });

      /// Tests for the equality operator
      test('equality should be based on id only', () {
        final contactWithSameId = contact.copyWith(firstName: 'Giuseppe');
        final contactWithDifferentId = contact.copyWith(id: '67890');

        expect(contact, equals(contactWithSameId));
        expect(contact, isNot(equals(contactWithDifferentId)));
      });
    });

    /// Grouping tests for extensions
    group('Extensions', () {
      /// Tests for the toNativeMap method
      test('toNativeMap should return a map with a String date', () {
        final nativeMap = contact.toNativeMap();

        expect(nativeMap['birthDate'], isA<String>());
        expect(nativeMap['birthDate'], birthDate.toString());
      });
    });
  });
}
