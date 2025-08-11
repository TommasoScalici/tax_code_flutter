import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/database_service.dart';

void main() {
  group('DatabaseService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DatabaseService databaseService;

    const testUserId = 'test-user-123';
    final testBirthplace = Birthplace(name: 'Palermo', state: 'PA');
    final testContact = Contact(
      id: 'contact-id-abc',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01G273M',
      birthPlace: testBirthplace,
      birthDate: DateTime(1980, 1, 1),
      listIndex: 0,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      databaseService = DatabaseService(firestore: fakeFirestore);
    });

    group('addOrUpdateContact', () {
      test('should correctly serialize and save a Contact object', () async {
        // Act
        await databaseService.addOrUpdateContact(testUserId, testContact);

        // Assert
        final snapshot = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('contacts')
            .doc(testContact.id)
            .get();

        expect(
          snapshot.exists,
          isTrue,
          reason: 'The document should be created',
        );
        expect(
          snapshot.data(),
          testContact.toJson(),
          reason: 'The document data should match the contact JSON',
        );
      });
    });

    group('removeContact', () {
      test('should delete an existing contact from the correct path', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('contacts')
            .doc(testContact.id)
            .set(testContact.toJson());

        // Act
        await databaseService.removeContact(testUserId, testContact.id);

        // Assert
        final snapshot = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('contacts')
            .doc(testContact.id)
            .get();

        expect(
          snapshot.exists,
          isFalse,
          reason: 'The document should be deleted',
        );
      });
    });

    group('getContactsStream', () {
      test('should emit a new list of contacts when data changes', () async {
        // Arrange
        final stream = databaseService.getContactsStream(testUserId);

        // Assert & Act
        unawaited(
          expectLater(
            stream,
            emitsInOrder([
              // 1. Appena ci si sottoscrive, lo stream emette lo stato attuale: una lista vuota.
              [],
              // 2. Dopo aver aggiunto un contatto, emette una lista contenente quel contatto.
              [testContact],
              // 3. Dopo averlo rimosso, emette di nuovo una lista vuota.
              [],
            ]),
          ),
        );

        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('contacts')
            .doc(testContact.id)
            .set(testContact.toJson());

        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('contacts')
            .doc(testContact.id)
            .delete();
      });
    });

    group('saveAllContacts', () {
      test(
        'should add new, update existing, and delete old contacts',
        () async {
          // Arrange
          final contactToDelete = testContact.copyWith(id: 'delete-me');
          final contactToUpdate = testContact.copyWith(
            id: 'update-me',
            firstName: 'Luigi',
          );
          final contactNew = testContact.copyWith(
            id: 'add-me',
            firstName: 'Anna',
          );

          final initialCollection = fakeFirestore
              .collection('users')
              .doc(testUserId)
              .collection('contacts');
          await initialCollection
              .doc(contactToDelete.id)
              .set(contactToDelete.toJson());
          await initialCollection
              .doc(contactToUpdate.id)
              .set(contactToUpdate.toJson());

          final contactUpdated = contactToUpdate.copyWith(firstName: 'Luca');
          final newContactsList = [contactUpdated, contactNew];

          // Act
          await databaseService.saveAllContacts(testUserId, newContactsList);

          // Assert
          final deletedDoc = await initialCollection
              .doc(contactToDelete.id)
              .get();
          expect(
            deletedDoc.exists,
            isFalse,
            reason: 'Old contact should be deleted',
          );

          final updatedDoc = await initialCollection
              .doc(contactToUpdate.id)
              .get();
          expect(
            updatedDoc.exists,
            isTrue,
            reason: 'Updated contact should exist',
          );
          expect(
            updatedDoc.data(),
            contactUpdated.toJson(),
            reason: 'Contact should have updated data',
          );

          final newDoc = await initialCollection.doc(contactNew.id).get();
          expect(newDoc.exists, isTrue, reason: 'New contact should be added');
          expect(newDoc.data(), contactNew.toJson());

          final finalSnapshot = await initialCollection.get();
          expect(
            finalSnapshot.docs.length,
            2,
            reason: 'The collection should have exactly 2 documents',
          );
        },
      );
    });

    group('saveUserData', () {
      test(
        'should create a new user document with createdAt timestamp',
        () async {
          // Arrange
          final mockUser = MockUser(
            uid: 'new-user-id',
            email: 'new.user@example.com',
            displayName: 'New User',
          );

          // Act
          await databaseService.saveUserData(mockUser);

          // Assert
          final snapshot = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .get();
          expect(snapshot.exists, isTrue);
          final data = snapshot.data()!;
          expect(data['email'], 'new.user@example.com');
          expect(data['createdAt'], isA<Timestamp>());
          expect(data['lastLogin'], isA<Timestamp>());
        },
      );

      test(
        'should update an existing user document without overwriting createdAt',
        () async {
          // Arrange
          final mockUser = MockUser(
            uid: 'existing-user-id',
            email: 'new.email@example.com', // Simuliamo un cambio email
          );
          final existingData = {
            'uid': mockUser.uid,
            'email': 'old.email@example.com',
            'createdAt': Timestamp.now(),
          };
          await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .set(existingData);

          // Act
          await databaseService.saveUserData(mockUser);

          // Assert
          final snapshot = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .get();
          expect(snapshot.exists, isTrue);
          final data = snapshot.data()!;

          // Verifichiamo che l'email sia aggiornata
          expect(data['email'], 'new.email@example.com');
          // Verifichiamo che lastLogin sia stato aggiunto/aggiornato
          expect(data['lastLogin'], isA<Timestamp>());
          // Verifichiamo che createdAt NON sia stato sovrascritto (grazie a merge: true)
          expect(data['createdAt'], existingData['createdAt']);
        },
      );
    });
  });
}
