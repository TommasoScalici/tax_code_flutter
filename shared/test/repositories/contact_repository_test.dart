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
    final box = await Hive.openBox<Contact>('contacts_test_uid');
    await box.clear();

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

  tearDownAll(() async {
    await contactsStreamController.close();
    await Hive.close();
  });

  Future<void> loginAndLoadInitialData(
      {List<Contact> initialContacts = const []}) async {
    final completer = Completer<void>();

    void listener() {
      if (!contactRepository.isLoading && !completer.isCompleted) {
        completer.complete();
      }
    }

    contactRepository.addListener(listener);
    fakeAuthService.login(fakeUser);
    contactsStreamController.add(initialContacts);
    await completer.future;
    contactRepository.removeListener(listener);
  }

  group('Initialization and Authentication', () {
    test(
      'should start with isLoading=false and empty contacts when not signed in',
      () {
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts, isEmpty);
      },
    );

    test('should clear contacts and stop loading when user signs out',
        () async {
      // Arrange
      await loginAndLoadInitialData(initialContacts: [contact1]);
      expect(contactRepository.contacts, isNotEmpty);

      // Act
      fakeAuthService.logout();
      await pumpEventQueue();

      // Assert
      expect(contactRepository.isLoading, isFalse);
      expect(contactRepository.contacts, isEmpty);
    });
  });

  group('Data Loading - Happy Path', () {
    test('should load contacts from Firestore and save to cache', () async {
      // Act
      await loginAndLoadInitialData(initialContacts: contactsList);

      // Assert
      expect(contactRepository.isLoading, isFalse);
      expect(contactRepository.contacts, equals(contactsList));

      final box = await Hive.openBox<Contact>('contacts_test_uid');
      expect(box.length, 2);
      expect(box.get('id1'), equals(contact1));
    });
  });

  group('Data Loading - Error Path', () {
    test(
      'should load contacts from cache when Firestore stream fails',
      () async {
        // Arrange
        final box = await Hive.openBox<Contact>('contacts_test_uid');
        await box.put(contact1.id, contact1);

        final completer = Completer<void>();
        contactRepository.addListener(() {
          if (!contactRepository.isLoading && !completer.isCompleted) {
            completer.complete();
          }
        });

        // Act
        fakeAuthService.login(fakeUser);
        final exception = Exception('Network failed');
        contactsStreamController.addError(exception);
        await completer.future;

        // Assert
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts.length, 1);
        expect(contactRepository.contacts.first, equals(contact1));
        verify(() => mockLogger.e(any(),
            error: exception, stackTrace: any(named: 'stackTrace'))).called(1);
      },
    );
  });

  group('CRUD Operations', () {
    test(
      'addOrUpdateContact should add a new contact and call database service',
      () async {
        // Arrange
        await loginAndLoadInitialData(initialContacts: [contact1]);

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
      'removeContact should remove contact and call database service',
      () async {
        // Arrange
        await loginAndLoadInitialData(initialContacts: [contact1]);

        // Act
        await contactRepository.removeContact(contact1);

        // Assert
        expect(contactRepository.contacts, isEmpty);
        verify(
          () => mockDbService.removeContact('test_uid', contact1.id),
        ).called(1);
        final box = await Hive.openBox<Contact>('contacts_test_uid');
        expect(box.isEmpty, isTrue);
      },
    );

    test(
      'updateContacts should re-index the list and trigger saveAllContacts',
      () async {
        // Arrange
        await loginAndLoadInitialData(initialContacts: [contact1, contact2]);
        final reorderedList = [contact2, contact1];

        // Act
        await contactRepository.updateContacts(reorderedList);

        // Assert
        expect(contactRepository.contacts.length, 2);
        final contact1Updated = contactRepository.contacts.firstWhere(
          (c) => c.id == 'id1',
        );
        expect(contact1Updated.listIndex, 1);

        final verificationResult = verify(
          () => mockDbService.saveAllContacts(captureAny(), captureAny()),
        );

        verificationResult.called(1);

        final capturedUserId = verificationResult.captured[0] as String;
        final capturedContacts =
            verificationResult.captured[1] as List<Contact>;

        expect(capturedUserId, 'test_uid');
        expect(
          capturedContacts,
          equals([
            contact2.copyWith(listIndex: 0),
            contact1.copyWith(listIndex: 1),
          ]),
        );
      },
    );

    test('addOrUpdateContact should update an existing contact', () async {
      // Arrange
      await loginAndLoadInitialData(initialContacts: [contact1]);
      expect(contactRepository.contacts.first.firstName, 'Mario');

      final contact1Updated = contact1.copyWith(firstName: 'Giovanni');

      // Act
      await contactRepository.addOrUpdateContact(contact1Updated);

      // Assert
      expect(contactRepository.contacts.length, 1);
      expect(contactRepository.contacts.first.firstName, 'Giovanni');
      verify(
        () => mockDbService.addOrUpdateContact('test_uid', contact1Updated),
      ).called(1);
    });

    test('addOrUpdateContact should log error when database service fails',
        () async {
      // Arrange
      await loginAndLoadInitialData(initialContacts: [contact1]);
      final exception = Exception('Update failed');
      when(() => mockDbService.addOrUpdateContact(any(), any()))
          .thenThrow(exception);

      // Act
      await contactRepository.addOrUpdateContact(contact2);

      // Assert
      expect(contactRepository.contacts.length, 2);
      verify(() => mockLogger.e(
            'Error adding/updating contact in Firebase',
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          )).called(1);
    });

    test('removeContact should log error when database service fails',
        () async {
      // Arrange
      await loginAndLoadInitialData(initialContacts: [contact1]);
      final exception = Exception('Remove failed');
      when(() => mockDbService.removeContact(any(), any()))
          .thenThrow(exception);

      // Act
      await contactRepository.removeContact(contact1);

      // Assert
      expect(contactRepository.contacts, isEmpty);
      verify(() => mockLogger.e(
            'Error removing contact from Firebase',
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          )).called(1);
    });
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

  group('Persistence Error Handling', () {
    test('should log an error when saving to Firebase fails', () async {
      final exception = Exception('Firebase write failed');
      when(() => mockDbService.saveAllContacts(any(), any()))
          .thenThrow(exception);

      // Arrange
      await loginAndLoadInitialData();

      // Act
      await contactRepository.updateContacts([]);

      // Assert
      verify(() => mockLogger.e('Error while saving contacts to Firebase',
          error: exception, stackTrace: any(named: 'stackTrace'))).called(1);
    });
  });
}
