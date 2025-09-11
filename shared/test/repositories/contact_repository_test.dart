import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/database_service.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_user.dart';

// --- Mocks ---
class MockDatabaseService extends Mock implements DatabaseService {}

class MockLogger extends Mock implements Logger {}

void main() {
  final fakeUser = FakeUser();
  final contact1 = Contact(
    id: 'id1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: '...',
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    birthDate: DateTime(1990),
    listIndex: 0,
  );
  final contact2 = Contact(
    id: 'id2',
    firstName: 'Luigi',
    lastName: 'Verdi',
    gender: 'M',
    taxCode: '...',
    birthPlace: const Birthplace(name: 'Milano', state: 'MI'),
    birthDate: DateTime(1992),
    listIndex: 1,
  );
  final contactsList = [contact1, contact2];

  // --- Setup ---
  late ContactRepository contactRepository;
  late FakeAuthService fakeAuthService;
  late MockDatabaseService mockDbService;
  late MockLogger mockLogger;
  late StreamController<List<Contact>> contactsStreamController;

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(BirthplaceAdapter());

    registerFallbackValue(Contact.empty());
    registerFallbackValue(<Contact>[]);
  });

  setUp(() async {
    // Clear any previously opened boxes
    await Hive.deleteFromDisk();

    contactsStreamController = StreamController<List<Contact>>.broadcast();
    fakeAuthService = FakeAuthService();
    mockDbService = MockDatabaseService();
    mockLogger = MockLogger();

    when(
      () => mockDbService.getContactsStream(any()),
    ).thenAnswer((_) => contactsStreamController.stream);
    when(
      () => mockDbService.addOrUpdateContact(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDbService.removeContact(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDbService.saveAllContacts(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockLogger.e(
        any(),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenAnswer((_) {});

    contactRepository = ContactRepository(
      authService: fakeAuthService,
      dbService: mockDbService,
      logger: mockLogger,
    );
  });

  tearDown(() async {
    await contactsStreamController.close();
  });

  tearDownAll(() async {
    contactRepository.dispose();
    await Hive.close();
  });

  Future<void> waitForLoading(Future<void> Function() action) async {
    final completer = Completer<void>();

    void listener() {
      if (!contactRepository.isLoading && !completer.isCompleted) {
        completer.complete();
      }
    }

    contactRepository.addListener(listener);

    await action();

    if (!contactRepository.isLoading && !completer.isCompleted) {
      completer.complete();
    }

    await completer.future;
    contactRepository.removeListener(listener);
  }

  group('Initialization and Authentication', () {
    test(
      'should start with isLoading=true and empty contacts when created without user',
      () {
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts, isEmpty);
      },
    );

    test(
      'should initialize correctly when created with an existing user',
      () async {
        // Arrange
        final preAuthService = FakeAuthService();
        preAuthService.login(fakeUser);

        // Act
        final repo = ContactRepository(
          authService: preAuthService,
          dbService: mockDbService,
          logger: mockLogger,
        );
        await pumpEventQueue();

        // Assert
        verify(() => mockDbService.getContactsStream(fakeUser.uid)).called(1);
        expect(repo.isLoading, isTrue);
      },
    );

    test('should load contacts when a user signs in', () async {
      // Assert initial state
      expect(contactRepository.isLoading, isFalse);
      expect(contactRepository.contacts, isEmpty);

      // Act
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add(contactsList);
      });

      // Assert
      expect(contactRepository.isLoading, isFalse);
      expect(contactRepository.contacts, equals(contactsList));
    });

    test(
      'should clear contacts and stop loading when user signs out',
      () async {
        // Arrange
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add(contactsList);
        });
        expect(contactRepository.contacts, isNotEmpty);

        // Act
        fakeAuthService.logout();
        await pumpEventQueue();

        // Assert
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts, isEmpty);
        verify(() => mockDbService.getContactsStream(fakeUser.uid)).called(2);
      },
    );
  });

  group('Data Loading', () {
    test(
      'should load from Firestore, update state, and save to cache',
      () async {
        // Act
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add(contactsList);
        });

        // Assert
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts, equals(contactsList));

        final box = await Hive.openBox<Contact>('contacts_test_uid');
        expect(box.values.toList(), equals(contactsList));
      },
    );

    test(
      'on initial load failure, should fallback to cache and still listen for future updates',
      () async {
        // Arrange
        final box = await Hive.openBox<Contact>('contacts_test_uid');
        await box.put(contact1.id, contact1);
        final exception = Exception('Network failed');

        // Act
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.addError(exception);
        });

        // Assert: Loaded from cache
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts.single, equals(contact1));
        verify(
          () => mockLogger.e(
            any(that: contains('falling back to cache')),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);

        // Assert: Still listening to the stream
        final updatedContacts = [contact1, contact2];
        contactsStreamController.add(updatedContacts);
        await pumpEventQueue();

        // Assert 2: Contacts updated
        expect(contactRepository.contacts, equals(updatedContacts));
      },
    );

    test('should log error if stream fails after initial load', () async {
      // Arrange
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add([contact1]);
      });
      expect(contactRepository.contacts.length, 1);

      // Act
      final exception = Exception('Stream broke');
      contactsStreamController.addError(exception);
      await pumpEventQueue();

      // Assert
      expect(contactRepository.contacts.length, 1); // State is preserved
      verify(
        () => mockLogger.e(
          'Error on contacts stream after initial load.',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });

  group('CRUD Operations', () {
    test(
      'addOrUpdateContact should add a new contact and persist it',
      () async {
        // Arrange
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add([contact1]);
        });

        // Act
        await contactRepository.addOrUpdateContact(contact2);

        // Assert
        expect(contactRepository.contacts, contains(contact2));
        expect(contactRepository.contacts.length, 2);
        verify(
          () => mockDbService.addOrUpdateContact('test_uid', contact2),
        ).called(1);

        final box = await Hive.openBox<Contact>('contacts_test_uid');
        expect(box.length, 2);
      },
    );

    test(
      'addOrUpdateContact should update an existing contact and persist it',
      () async {
        // Arrange
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add([contact1]);
        });
        final contact1Updated = contact1.copyWith(firstName: 'Giovanni');

        // Act
        await contactRepository.addOrUpdateContact(contact1Updated);

        // Assert
        expect(contactRepository.contacts.length, 1);
        expect(contactRepository.contacts.first.firstName, 'Giovanni');
        verify(
          () => mockDbService.addOrUpdateContact('test_uid', contact1Updated),
        ).called(1);
      },
    );

    test('removeContact should remove a contact and persist change', () async {
      // Arrange
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add(contactsList);
      });

      // Act
      await contactRepository.removeContact(contact1);

      // Assert
      expect(contactRepository.contacts, isNot(contains(contact1)));
      expect(contactRepository.contacts.length, 1);
      verify(
        () => mockDbService.removeContact('test_uid', contact1.id),
      ).called(1);
      final box = await Hive.openBox<Contact>('contacts_test_uid');
      expect(box.length, 1);
    });

    test(
      'updateContacts should re-index the list and call saveAllContacts',
      () async {
        // Arrange
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add(contactsList);
        });
        final reorderedList = [contact2, contact1];

        // Act
        await contactRepository.updateContacts(reorderedList);

        // Assert
        final expectedList = [
          contact2.copyWith(listIndex: 0),
          contact1.copyWith(listIndex: 1),
        ];
        expect(contactRepository.contacts, equals(expectedList));

        final captured = verify(
          () => mockDbService.saveAllContacts('test_uid', captureAny()),
        ).captured;
        expect(captured.first, equals(expectedList));
      },
    );
  });

  group('Error Handling', () {
    test('addOrUpdateContact should log error on DB failure', () async {
      // Arrange
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add([contact1]);
      });
      final exception = Exception('Update failed');
      when(
        () => mockDbService.addOrUpdateContact(any(), any()),
      ).thenThrow(exception);

      // Act
      await contactRepository.addOrUpdateContact(contact2);

      // Assert
      expect(contactRepository.contacts.length, 2); // UI is still updated
      verify(
        () => mockLogger.e(
          'Error adding/updating contact in Firebase',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });

    test('removeContact should log error on DB failure', () async {
      // Arrange
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add([contact1]);
      });
      final exception = Exception('Remove failed');
      when(
        () => mockDbService.removeContact(any(), any()),
      ).thenThrow(exception);

      // Act
      await contactRepository.removeContact(contact1);

      // Assert
      expect(contactRepository.contacts, isEmpty); // UI is still updated
      verify(
        () => mockLogger.e(
          'Error removing contact from Firebase',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });

    test('saveContacts should log error on DB failure', () async {
      // Arrange
      await waitForLoading(() async {
        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        contactsStreamController.add(contactsList);
      });
      final exception = Exception('Firebase write failed');
      when(
        () => mockDbService.saveAllContacts(any(), any()),
      ).thenThrow(exception);

      // Act
      await contactRepository.updateContacts([]); // triggers saveContacts

      // Assert
      verify(
        () => mockLogger.e(
          'Error while saving contacts to Firebase',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });

  group('Disposed State', () {
    test(
      'should not perform actions or call services after being disposed',
      () async {
        // Arrange
        await waitForLoading(() async {
          fakeAuthService.login(fakeUser);
          await pumpEventQueue();
          contactsStreamController.add([contact1]);
        });

        verify(() => mockDbService.getContactsStream(fakeUser.uid)).called(2);

        // Act
        contactRepository.dispose();

        clearInteractions(mockDbService);

        // Act 2
        await contactRepository.addOrUpdateContact(contact2);
        await contactRepository.removeContact(contact1);
        await contactRepository.updateContacts([]);

        contactsStreamController.add([contact1, contact2]);
        await pumpEventQueue();

        fakeAuthService.login(fakeUser);
        await pumpEventQueue();
        fakeAuthService.logout();
        await pumpEventQueue();

        // Assert
        verifyNever(() => mockDbService.addOrUpdateContact(any(), any()));
        verifyNever(() => mockDbService.removeContact(any(), any()));
        verifyNever(() => mockDbService.saveAllContacts(any(), any()));
        verifyNever(() => mockDbService.getContactsStream(any()));
      },
    );
  });

  group('Guard Clauses', () {
    test('operations should do nothing when user is not signed in', () async {
      // Arrange
      expect(fakeAuthService.isSignedIn, isFalse);

      // Act
      await contactRepository.addOrUpdateContact(contact1);
      await contactRepository.removeContact(contact1);
      await contactRepository.saveContacts();

      // Assert
      verifyNever(() => mockDbService.addOrUpdateContact(any(), any()));
      verifyNever(() => mockDbService.removeContact(any(), any()));
      verifyNever(() => mockDbService.saveAllContacts(any(), any()));
    });
  });
}
