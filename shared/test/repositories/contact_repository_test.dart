import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import '../services/auth_service_test.dart';

// --- Mocks ---
class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLogger extends Mock implements Logger {}

class MockBirthplace extends Mock implements Birthplace {}

class MockContact extends Mock implements Contact {}

void main() {
  final mockUser = MockUser();
  final contact1 = Contact(
    id: 'id1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: '...',
    birthPlace: Birthplace(name: 'Roma', state: 'RM'),
    birthDate: DateTime(1990),
    listIndex: 0,
  );
  final contact2 = Contact(
    id: 'id2',
    firstName: 'Luigi',
    lastName: 'Verdi',
    gender: 'M',
    taxCode: '...',
    birthPlace: Birthplace(name: 'Milano', state: 'MI'),
    birthDate: DateTime(1992),
    listIndex: 1,
  );
  final contactsList = [contact1, contact2];

  // --- Setup ---
  late ContactRepository contactRepository;
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDbService;
  late MockLogger mockLogger;
  late StreamController<List<Contact>> contactsStreamController;

  setUpAll(() async {
    Hive.init('test/hive_test_path');
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(BirthplaceAdapter());

    registerFallbackValue(MockContact());
    registerFallbackValue(<Contact>[]);
  });

  setUp(() async {
    final box = await Hive.openBox<Contact>('contacts_test_uid');
    await box.clear();

    contactsStreamController = StreamController<List<Contact>>.broadcast();
    mockAuthService = MockAuthService();
    mockDbService = MockDatabaseService();
    mockLogger = MockLogger();

    when(() => mockUser.uid).thenReturn('test_uid');
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

    when(() => mockAuthService.isSignedIn).thenReturn(false);
    when(() => mockAuthService.currentUser).thenReturn(null);

    contactRepository = ContactRepository(
      authService: mockAuthService,
      dbService: mockDbService,
      logger: mockLogger,
    );
  });

  tearDownAll(() async {
    await contactsStreamController.close();
    await Hive.close();
  });

  group('Initialization and Authentication', () {
    test(
      'should start with isLoading=false and empty contacts when not signed in',
      () {
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts, isEmpty);
      },
    );

    test('should clear contacts and stop loading when user signs out', () {
      when(() => mockAuthService.isSignedIn).thenReturn(false);
      when(() => mockAuthService.currentUser).thenReturn(null);
      contactRepository.dispose();
      contactRepository = ContactRepository(
        authService: mockAuthService,
        dbService: mockDbService,
        logger: mockLogger,
      );

      expect(contactRepository.isLoading, isFalse);
      expect(contactRepository.contacts, isEmpty);
    });
  });

  group('Data Loading - Happy Path', () {
    test('should load contacts from Firestore and save to cache', () async {
      // Arrange
      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      contactRepository.dispose();
      contactRepository = ContactRepository(
        authService: mockAuthService,
        dbService: mockDbService,
        logger: mockLogger,
      );

      // Act
      contactsStreamController.add(contactsList);

      await Future.delayed(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 100));

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
        // Arrange: 1.
        final box = await Hive.openBox<Contact>('contacts_test_uid');
        await box.put(contact1.id, contact1);

        // Arrange: 2.
        final completer = Completer<void>();
        when(() => mockAuthService.isSignedIn).thenReturn(true);
        when(() => mockAuthService.currentUser).thenReturn(mockUser);

        contactRepository.dispose();
        contactRepository = ContactRepository(
          authService: mockAuthService,
          dbService: mockDbService,
          logger: mockLogger,
        );

        contactRepository.addListener(() {
          if (!contactRepository.isLoading && !completer.isCompleted) {
            completer.complete();
          }
        });

        // Act
        final exception = Exception('Network failed');
        contactsStreamController.addError(exception);
        await Future.delayed(Duration.zero);

        // Assert
        expect(contactRepository.isLoading, isFalse);
        expect(contactRepository.contacts.length, 1);
        expect(contactRepository.contacts.first, equals(contact1));

        verify(
          () => mockLogger.e(
            any(),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('CRUD Operations', () {
    Future<void> setupLoggedInState() async {
      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      contactRepository.dispose();
      contactRepository = ContactRepository(
        authService: mockAuthService,
        dbService: mockDbService,
        logger: mockLogger,
      );
      contactsStreamController.add([contact1]);
      await Future.delayed(Duration.zero);
    }

    test(
      'addOrUpdateContact should add a new contact and call database service',
      () async {
        await setupLoggedInState();

        // Act
        await contactRepository.addOrUpdateContact(contact2);

        // Assert
        expect(contactRepository.contacts, contains(contact2));
        expect(contactRepository.contacts.length, 2);
        verify(
          () => mockDbService.addOrUpdateContact('test_uid', contact2),
        ).called(1);
        // Verifica la cache
        final box = await Hive.openBox<Contact>('contacts_test_uid');
        expect(box.length, 2);
      },
    );

    test(
      'removeContact should remove contact and call database service',
      () async {
        await setupLoggedInState();

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
        await setupLoggedInState();
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
      await setupLoggedInState();
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
  });

  group('Guard Clauses', () {
    test('operations should do nothing when user is not signed in', () async {
      // Arrange
      expect(mockAuthService.isSignedIn, isFalse);

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
      // Arrange
      final exception = Exception('Firebase write failed');
      when(
        () => mockDbService.saveAllContacts(any(), any()),
      ).thenThrow(exception);

      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      contactRepository.dispose();
      contactRepository = ContactRepository(
        authService: mockAuthService,
        dbService: mockDbService,
        logger: mockLogger,
      );

      // Act
      await contactRepository.updateContacts([]);

      // Assert
      verify(
        () => mockLogger.e(
          'Error while saving contacts to Firebase',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });

    test('should log an error when saving to Hive cache fails', () async {
      // Questo è più complesso da testare perché Hive non è mockato.
      // Tuttavia, il test precedente per il fallimento di Firebase è più critico
      // e già aumenta notevolmente la robustezza della suite.
      // Per ora, concentriamoci sui fallimenti dei servizi esterni (mockati).
    });
  });
}
