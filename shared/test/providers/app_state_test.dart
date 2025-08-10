import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:file/memory.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';
import 'package:shared/providers/shared_preferences_async.dart';
import 'package:shared/services/database_service.dart';

///
/// A mock implementation of [PathProviderPlatform].
/// This is necessary to prevent unit tests from crashing when they
/// try to access the device's file system via platform channels.
///
class MockPathProviderPlatform
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  static const String fakeDocumentsPath = '/fake_documents_path';

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return fakeDocumentsPath;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

class MockLogger extends Mock implements Logger {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFile extends Mock implements File {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  final memoryFileSystem = MemoryFileSystem();

  IOOverrides.runZoned(
    () {
      ///
      /// Theme Management Tests
      /// This section tests the theme management functionality of the AppState.
      /// It verifies that the theme can be toggled between light and dark modes
      /// and that the selected theme is persisted in shared preferences.
      ///
      group('Theme Management', () {
        late AppState appState;
        late MockDatabaseService mockDbService;
        late MockFirebaseAuth mockAuth;
        late MockLogger mockLogger;
        late MockSharedPreferencesAsync mockSharedPreferences;

        setUp(() {
          mockAuth = MockFirebaseAuth();
          mockDbService = MockDatabaseService();
          mockLogger = MockLogger();
          mockSharedPreferences = MockSharedPreferencesAsync();
        });

        void initializeAppState({required String initialTheme}) {
          when(
            () => mockSharedPreferences.getString('theme'),
          ).thenAnswer((_) async => initialTheme);

          appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            logger: mockLogger,
            prefs: mockSharedPreferences,
          );
        }

        test('should switch theme from light to dark', () async {
          initializeAppState(initialTheme: 'light');
          await appState.loadTheme();

          when(
            () => mockSharedPreferences.setString('theme', 'dark'),
          ).thenAnswer((_) async => true);

          appState.toggleTheme();
          expect(appState.theme, 'dark');
          verify(
            () => mockSharedPreferences.setString('theme', 'dark'),
          ).called(1);
        });

        test('should switch theme from dark to light', () async {
          initializeAppState(initialTheme: 'dark');
          await appState.loadTheme();

          when(
            () => mockSharedPreferences.setString('theme', 'light'),
          ).thenAnswer((_) async => true);

          appState.toggleTheme();
          expect(appState.theme, 'light');
          verify(
            () => mockSharedPreferences.setString('theme', 'light'),
          ).called(1);
        });
      });

      ///
      /// AppState Logic Tests
      /// This section tests the functionality of adding contacts to the AppState.
      /// It verifies that contacts can be added, updated, and that the
      /// Firestore stream is handled correctly.
      ///
      group('AppState Logic', () {
        late DatabaseService dbService;
        late FakeFirebaseFirestore fakeFirestore;
        late MockSharedPreferencesAsync mockSharedPreferences;
        late MockFirebaseAuth mockAuth;
        late MockLogger mockLogger;
        late MockUser mockUser;

        setUp(() {
          final directory = Directory(
            MockPathProviderPlatform.fakeDocumentsPath,
          );
          if (directory.existsSync()) directory.deleteSync(recursive: true);
          directory.createSync(recursive: true);

          fakeFirestore = FakeFirebaseFirestore();
          dbService = DatabaseService(firestore: fakeFirestore);
          mockSharedPreferences = MockSharedPreferencesAsync();
          mockUser = MockUser(isAnonymous: false, uid: 'test_user');
          mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
          mockLogger = MockLogger();

          when(
            () => mockSharedPreferences.getString('theme'),
          ).thenAnswer((_) async => 'light');
        });

        Future<AppState> createInitializedAppState({
          List<Contact>? initialContacts,
        }) async {
          if (initialContacts != null) {
            for (final contact in initialContacts) {
              await fakeFirestore
                  .collection('users')
                  .doc(mockUser.uid)
                  .collection('contacts')
                  .doc(contact.id)
                  .set(contact.toMap());
            }
          }

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: dbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          await appState.initializationComplete;
          return appState;
        }

        // --- Tests for main paths (happy paths) ---

        test('should initialize with contacts from firestore', () async {
          final contact = Contact.empty().copyWith(
            id: 'c1',
            firstName: 'Mario',
          );
          final appState = await createInitializedAppState(
            initialContacts: [contact],
          );
          expect(appState.contacts.length, 1);
          expect(appState.contacts.first.firstName, 'Mario');
        });

        test('addContact should add a new contact', () async {
          // Arrange
          final appState = await createInitializedAppState();
          final contact = Contact.empty().copyWith(
            id: 'c1',
            firstName: 'Luigi',
          );

          // Act
          await appState.addContact(contact);

          // Assert
          expect(appState.contacts.length, 1);
          expect(appState.contacts.first.firstName, 'Luigi');

          final doc = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .collection('contacts')
              .doc('c1')
              .get();

          expect(doc.exists, isTrue);
          expect(doc.data()?['firstName'], 'Luigi');
        });

        test('addContact should update an existing contact', () async {
          // Arrange
          final contact = Contact.empty().copyWith(
            id: 'c1',
            firstName: 'Mario',
          );
          final appState = await createInitializedAppState(
            initialContacts: [contact],
          );
          final updatedContact = contact.copyWith(firstName: 'Luigi');

          // Act
          await appState.addContact(updatedContact);

          // Assert
          expect(appState.contacts.length, 1);
          expect(appState.contacts.first.firstName, 'Luigi');

          final doc = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .collection('contacts')
              .doc('c1')
              .get();

          expect(doc.data()?['firstName'], 'Luigi');
        });

        test('removeContact should remove a contact', () async {
          // Arrange
          final contact = Contact.empty().copyWith(id: 'c1');
          final appState = await createInitializedAppState(
            initialContacts: [contact],
          );

          // Act
          await appState.removeContact(contact);

          // Assert
          expect(appState.contacts.isEmpty, isTrue);

          final doc = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .collection('contacts')
              .doc('c1')
              .get();

          expect(doc.exists, isFalse);
        });

        test('updateContacts should replace the list and save', () async {
          // Arrange
          final initialContacts = [Contact.empty().copyWith(id: 'c1')];
          final appState = await createInitializedAppState(
            initialContacts: initialContacts,
          );
          final newContacts = [
            Contact.empty().copyWith(id: 'c2', listIndex: 0),
            Contact.empty().copyWith(id: 'c3', listIndex: 1),
          ];

          // Act
          await appState.updateContacts(newContacts);

          // Assert
          expect(appState.contacts.length, 2);
          expect(appState.contacts.first.id, 'c2');

          final contactsCollection = fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .collection('contacts');

          final oldDoc = await contactsCollection.doc('c1').get();
          expect(oldDoc.exists, isFalse);

          final newDoc2 = await contactsCollection.doc('c2').get();
          final newDoc3 = await contactsCollection.doc('c3').get();
          expect(newDoc2.exists, isTrue);
          expect(newDoc3.exists, isTrue);
        });

        test('setSearchState should update the search state', () async {
          final appState = await createInitializedAppState();
          expect(appState.isSearching, isFalse);
          appState.setSearchState(true);
          expect(appState.isSearching, isTrue);
        });

        // --- Auth Tests ---

        test('should clear contacts and stop loading when user logs out', () {
          fakeAsync((async) {
            mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

            final appState = AppState.withMocks(
              auth: mockAuth,
              dbService: dbService,
              logger: mockLogger,
              prefs: mockSharedPreferences,
            );

            async.flushMicrotasks();
            mockAuth.signOut();

            async.flushMicrotasks();

            expect(appState.currentUser, isNull);
            expect(appState.contacts.isEmpty, isTrue);
            expect(appState.isLoading, isFalse);
          });
        });

        // --- Test for user data management ---

        test('saveUserData should include createdAt for a new user', () async {
          // Arrange
          final appState = await createInitializedAppState();

          // Act
          await appState.saveUserData(mockUser);

          // Assert
          final userDoc = await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .get();

          expect(userDoc.exists, isTrue);
          expect(userDoc.data(), contains('createdAt'));
        });

        test('saveUserData should log error on failure', () async {
          // Arrange
          final mockDbService = MockDatabaseService();

          when(
            () => mockDbService.saveUserData(any()),
          ).thenThrow(Exception('DB Error'));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          // Act
          await appState.saveUserData(mockUser);

          // Assert
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        });

        // --- Tests for main and guard clauses

        test(
          'methods should do nothing when user is not logged in (Guard Clauses)',
          () async {
            // ARRANGE: Creiamo le nostre dipendenze mock
            final mockAuthLoggedOut = MockFirebaseAuth(signedIn: false);
            final mockDbService = MockDatabaseService();
            final dummyContact = Contact.empty().copyWith(id: 'dummy');

            final appState = AppState.withMocks(
              auth: mockAuthLoggedOut,
              dbService: mockDbService,
              prefs: mockSharedPreferences,
              logger: mockLogger,
            );

            // ACT
            await appState.addContact(dummyContact);
            await appState.removeContact(dummyContact);
            await appState.saveContacts();

            // VERIFY
            verifyNever(() => mockDbService.addOrUpdateContact(any(), any()));
            verifyNever(() => mockDbService.removeContact(any(), any()));
            verifyNever(() => mockDbService.saveAllContacts(any(), any()));
          },
        );

        // --- Tests for errors and edge cases ---

        test(
          'Firestore stream error should trigger loading from cache',
          () async {
            // Arrange
            final mockDbService = MockDatabaseService();
            final streamController = StreamController<List<Contact>>();

            when(
              () => mockDbService.getContactsStream(any()),
            ).thenAnswer((_) => streamController.stream);

            final cachedContact = Contact.empty().copyWith(id: 'cached');
            final cacheFile = File(
              '${MockPathProviderPlatform.fakeDocumentsPath}/contacts_${mockUser.uid}.json',
            );
            await cacheFile.writeAsString(jsonEncode([cachedContact.toJson()]));

            final appState = AppState.withMocks(
              auth: mockAuth,
              dbService: mockDbService,
              logger: mockLogger,
              prefs: mockSharedPreferences,
            );

            await Future.delayed(Duration.zero);

            // Act
            streamController.addError(Exception('Connection failed'));
            await appState.initializationComplete;

            // Assert
            expect(appState.contacts.length, 1);
            expect(appState.contacts.first.id, 'cached');
            verify(
              () => mockLogger.e(
                any(),
                error: any(named: 'error'),
                stackTrace: any(named: 'stackTrace'),
              ),
            ).called(1);

            await streamController.close();
          },
        );

        test('addContact should log error if firestore fails', () async {
          // Arrange
          final mockDbService = MockDatabaseService();
          when(
            () => mockDbService.addOrUpdateContact(any(), any()),
          ).thenThrow(FirebaseException(plugin: 'test'));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );
          final contact = Contact.empty().copyWith(id: 'c1');

          // Act
          await appState.addContact(contact);

          // Assert
          expect(appState.contacts.length, 1);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        });

        test('removeContact should log error if firestore fails', () async {
          // Arrange
          final mockDbService = MockDatabaseService();
          final contact = Contact.empty().copyWith(id: 'c1');

          when(
            () => mockDbService.removeContact(any(), any()),
          ).thenThrow(FirebaseException(plugin: 'test'));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          // Act
          await appState.removeContact(contact);

          // Assert
          expect(appState.contacts.isEmpty, isTrue);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        });

        test('removeContact should log error if firestore fails', () async {
          // Arrange
          final mockDbService = MockDatabaseService();
          final contact = Contact.empty().copyWith(id: 'c1');

          when(
            () => mockDbService.removeContact(any(), any()),
          ).thenThrow(FirebaseException(plugin: 'test'));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          // Act
          await appState.removeContact(contact);

          // Assert
          expect(appState.contacts.isEmpty, isTrue);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        });

        test('saveContacts should log error on failure', () async {
          // Arrange
          final mockDbService = MockDatabaseService();
          when(
            () => mockDbService.saveAllContacts(any(), any()),
          ).thenThrow(Exception('Batch failed'));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          // Act
          await appState.saveContacts();

          // Assert
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        });

        test('saveUserData should handle non-null user properties', () async {
          // Arrange
          final appState = await createInitializedAppState();
          final userWithData = MockUser(
            uid: 'test_user_with_data',
            displayName: 'Mario Rossi',
            email: 'mario.rossi@example.com',
            photoURL: 'http://example.com/photo.jpg',
          );

          // Act
          await appState.saveUserData(userWithData);

          // Assert
          final userDoc = await fakeFirestore
              .collection('users')
              .doc(userWithData.uid)
              .get();

          expect(userDoc.exists, isTrue);
          final data = userDoc.data();
          expect(data?['displayName'], 'Mario Rossi');
          expect(data?['email'], 'mario.rossi@example.com');
          expect(data?['photoURL'], 'http://example.com/photo.jpg');
          expect(data, contains('createdAt'));
        });

        test('should correctly handle subsequent Firestore updates', () async {
          // Arrange
          final appState = await createInitializedAppState(
            initialContacts: [Contact.empty().copyWith(id: 'c1')],
          );
          expect(appState.isLoading, isFalse);

          int listenerCallCount = 0;
          appState.addListener(() => listenerCallCount++);

          // Act
          final newContactData = Contact.empty().copyWith(id: 'c2').toMap();
          await fakeFirestore
              .collection('users')
              .doc(mockUser.uid)
              .collection('contacts')
              .doc('c2')
              .set(newContactData);

          await Future.delayed(Duration.zero);

          // Assert
          expect(appState.contacts.length, 2);
          expect(listenerCallCount, isPositive);
        });

        // --- Tests of Locale Cache ---

        test(
          'should load from empty cache if cache file does not exist',
          () async {
            // Arrange
            final mockDbService = MockDatabaseService();
            when(
              () => mockDbService.getContactsStream(any()),
            ).thenAnswer((_) => Stream.error(Exception('Connection failed')));

            final appState = AppState.withMocks(
              auth: mockAuth,
              dbService: mockDbService,
              prefs: mockSharedPreferences,
              logger: mockLogger,
            );

            // Act
            await Future.delayed(Duration.zero);
            await appState.initializationComplete;

            // Assert
            expect(appState.contacts.isEmpty, isTrue);
          },
        );

        test('should handle error when reading corrupted cache file', () async {
          // Arrange
          final cacheFile = File(
            '${MockPathProviderPlatform.fakeDocumentsPath}/contacts_${mockUser.uid}.json',
          );
          await cacheFile.writeAsString('{"invalid_json":}');

          final mockDbService = MockDatabaseService();
          when(
            () => mockDbService.getContactsStream(any()),
          ).thenAnswer((_) => Stream.error(Exception('Connection failed')));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          // Act
          await Future.delayed(Duration.zero);
          await appState.initializationComplete;

          // Assert
          expect(appState.contacts.isEmpty, isTrue);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(2);
        });

        test('should handle error when saving to local cache', () async {
          // Arrange
          final mockCacheFile = MockFile();
          when(
            () =>
                mockCacheFile.writeAsString(any(), flush: any(named: 'flush')),
          ).thenThrow(const FileSystemException('Disk is full!'));

          // Usiamo un IOOverrides specifico per questo test
          await IOOverrides.runZoned(
            () async {
              final mockDbService = MockDatabaseService();
              when(
                () => mockDbService.addOrUpdateContact(any(), any()),
              ).thenAnswer((_) async {});

              final appState = AppState.withMocks(
                auth: mockAuth,
                dbService: mockDbService,
                prefs: mockSharedPreferences,
                logger: mockLogger,
              );

              clearInteractions(mockLogger);

              final contact = Contact.empty().copyWith(id: 'c1');

              await appState.addContact(contact);

              final verification = verify(
                () => mockLogger.e(
                  any(),
                  error: captureAny(named: 'error'),
                  stackTrace: any(named: 'stackTrace'),
                ),
              );

              verification.called(1);

              final capturedError = verification.captured.first as Exception;
              expect(capturedError, isA<FileSystemException>());
            },
            createFile: (String path) {
              final cacheFilePath =
                  '${MockPathProviderPlatform.fakeDocumentsPath}/contacts_${mockUser.uid}.json';
              if (path == cacheFilePath) {
                return mockCacheFile;
              }
              return memoryFileSystem.file(path);
            },
          );
        });

        test('dispose should cancel contacts subscription', () async {
          // Arrange
          final mockDbService = MockDatabaseService();
          final streamController = StreamController<List<Contact>>();

          when(
            () => mockDbService.getContactsStream(any()),
          ).thenAnswer((_) => streamController.stream);

          // Mock auth state to have a user signed in
          when(
            () => mockAuth.authStateChanges(),
          ).thenAnswer((_) => Stream.value(mockUser));

          final appState = AppState.withMocks(
            auth: mockAuth,
            dbService: mockDbService,
            prefs: mockSharedPreferences,
            logger: mockLogger,
          );

          await appState.initializationComplete;

          // Act
          appState.dispose();

          // Assert
          expect(streamController.hasListener, isFalse);

          // Cleanup
          await streamController.close();
        });
      });
    },
    createDirectory: (path) => memoryFileSystem.directory(path),
    createFile: (path) => memoryFileSystem.file(path),
    getCurrentDirectory: () => memoryFileSystem.currentDirectory,
  );
}
