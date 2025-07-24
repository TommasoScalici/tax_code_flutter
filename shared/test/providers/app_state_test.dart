import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/memory.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import 'app_state_test.mocks.dart';

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

@GenerateMocks([
  CollectionReference,
  DocumentReference,
  FirebaseFirestore,
  QuerySnapshot,
  QueryDocumentSnapshot,
  SharedPreferencesAsync,
  WriteBatch,
])
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
        late MockSharedPreferencesAsync mockSharedPreferences;

        setUp(() async {
          mockSharedPreferences = MockSharedPreferencesAsync();

          when(
            mockSharedPreferences.getString(any),
          ).thenAnswer((_) async => 'light');

          appState = AppState(
            prefs: mockSharedPreferences,
            auth: MockFirebaseAuth(),
            firestore: MockFirebaseFirestore(),
          );
        });

        test('should switch theme from light to dark', () async {
          when(
            mockSharedPreferences.setString(any, any),
          ).thenAnswer((_) async => true);

          appState.toggleTheme();
          expect(appState.theme, 'dark');
          verify(mockSharedPreferences.setString('theme', 'dark')).called(1);
        });
      });

      ///
      /// Contact Management Tests
      /// This section tests the functionality of adding contacts to the AppState.
      /// It verifies that contacts can be added, removed, and updated,
      /// and that these changes are reflected in Firestore.
      ///
      group('Contact Management', () {
        late MockSharedPreferencesAsync mockSharedPreferences;
        late MockFirebaseAuth mockAuth;
        late MockFirebaseFirestore mockFirestore;
        late MockUser mockUser;
        late StreamController<QuerySnapshot<Map<String, dynamic>>>
        contactsStreamController;

        late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
        late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
        late MockCollectionReference<Map<String, dynamic>>
        mockContactsCollection;

        setUp(() async {
          final directory = Directory(
            MockPathProviderPlatform.fakeDocumentsPath,
          );
          if (directory.existsSync()) directory.deleteSync(recursive: true);
          directory.createSync(recursive: true);

          mockFirestore = MockFirebaseFirestore();
          mockSharedPreferences = MockSharedPreferencesAsync();
          mockUser = MockUser(isAnonymous: false, uid: 'test_user');
          mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

          contactsStreamController =
              StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();

          when(
            mockSharedPreferences.getString(any),
          ).thenAnswer((_) async => 'light');

          mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
          mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
          mockContactsCollection =
              MockCollectionReference<Map<String, dynamic>>();

          when(
            mockFirestore.collection('users'),
          ).thenReturn(mockUsersCollection);
          when(mockUsersCollection.doc(mockUser.uid)).thenReturn(mockUserDoc);
          when(
            mockUserDoc.collection('contacts'),
          ).thenReturn(mockContactsCollection);
          when(
            mockContactsCollection.snapshots(),
          ).thenAnswer((_) => contactsStreamController.stream);
        });

        tearDown(() {
          contactsStreamController.close();
        });

        Future<AppState> createInitializedAppState({
          List<Contact>? initialContacts,
        }) async {
          final appState = AppState(
            prefs: mockSharedPreferences,
            auth: mockAuth,
            firestore: mockFirestore,
          );

          await Future.delayed(Duration.zero);

          final initialDocs = (initialContacts ?? []).map((contact) {
            final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
            when(mockDoc.data()).thenReturn(contact.toMap());
            when(mockDoc.id).thenReturn(contact.id);
            return mockDoc;
          }).toList();

          final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
          when(mockSnapshot.docs).thenReturn(initialDocs);

          contactsStreamController.add(mockSnapshot);
          await appState.initializationComplete;
          return appState;
        }

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

        test('addContact should add to list and save to firestore', () async {
          final appState = await createInitializedAppState();
          final contact = Contact.empty().copyWith(
            id: 'c1',
            firstName: 'Luigi',
          );
          final mockContactDoc = MockDocumentReference<Map<String, dynamic>>();

          when(
            mockContactsCollection.doc(contact.id),
          ).thenReturn(mockContactDoc);
          when(mockContactDoc.set(any)).thenAnswer((_) async {});

          await appState.addContact(contact);

          expect(appState.contacts.length, 1);
          expect(appState.contacts.first.firstName, 'Luigi');
          verify(mockContactDoc.set(contact.toMap())).called(1);

          final cacheFile = File(
            '${MockPathProviderPlatform.fakeDocumentsPath}/contacts_${mockUser.uid}.json',
          );
          expect(await cacheFile.exists(), isTrue);
        });

        test('removeContact should remove from list and firestore', () async {
          final contact = Contact.empty().copyWith(
            id: 'c1',
            firstName: 'Luigi',
          );
          final appState = await createInitializedAppState(
            initialContacts: [contact],
          );

          final mockContactDoc = MockDocumentReference<Map<String, dynamic>>();
          when(
            mockContactsCollection.doc(contact.id),
          ).thenReturn(mockContactDoc);
          when(mockContactDoc.delete()).thenAnswer((_) async {});

          await appState.removeContact(contact);

          expect(appState.contacts.isEmpty, isTrue);
          verify(mockContactDoc.delete()).called(1);
          final cacheFile = File(
            '${MockPathProviderPlatform.fakeDocumentsPath}/contacts_${mockUser.uid}.json',
          );
          final cacheContent = jsonDecode(await cacheFile.readAsString());
          expect(cacheContent, isEmpty);
        });

        test(
          'updateContacts should reorder list and save to firestore',
          () async {
            final contact1 = Contact.empty().copyWith(
              id: 'c1',
              firstName: 'Mario',
              listIndex: 0,
            );
            final contact2 = Contact.empty().copyWith(
              id: 'c2',
              firstName: 'Luigi',
              listIndex: 1,
            );
            final appState = await createInitializedAppState(
              initialContacts: [contact1, contact2],
            );

            final mockWriteBatch = MockWriteBatch();
            when(mockFirestore.batch()).thenReturn(mockWriteBatch);
            final mockInitialSnapshot =
                MockQuerySnapshot<Map<String, dynamic>>();
            when(
              mockContactsCollection.get(),
            ).thenAnswer((_) async => mockInitialSnapshot);
            when(mockInitialSnapshot.docs).thenReturn([]);
            final mockDocRef1 = MockDocumentReference<Map<String, dynamic>>();
            final mockDocRef2 = MockDocumentReference<Map<String, dynamic>>();
            when(mockContactsCollection.doc('c1')).thenReturn(mockDocRef1);
            when(mockContactsCollection.doc('c2')).thenReturn(mockDocRef2);

            final reorderedList = [contact2, contact1];
            await appState.updateContacts(reorderedList);

            expect(appState.contacts.first.firstName, 'Luigi');
            verify(
              mockWriteBatch.set(
                any,
                argThat(
                  allOf([
                    containsPair('id', 'c2'),
                    containsPair('listIndex', 0),
                  ]),
                ),
              ),
            ).called(1);
            verify(
              mockWriteBatch.set(
                any,
                argThat(
                  allOf([
                    containsPair('id', 'c1'),
                    containsPair('listIndex', 1),
                  ]),
                ),
              ),
            ).called(1);
            verify(mockWriteBatch.commit()).called(1);
          },
        );

        test('should clear user data on logout', () async {
          final contact = Contact.empty().copyWith(id: 'c1');
          final appState = await createInitializedAppState(
            initialContacts: [contact],
          );
          expect(
            appState.contacts.isNotEmpty,
            isTrue,
            reason: 'Precondition failed',
          );

          await mockAuth.signOut();
          await appState.initializationComplete;

          expect(appState.contacts.isEmpty, isTrue);
          expect(appState.currentUser, isNull);
        });
      });
    },
    createDirectory: (path) => memoryFileSystem.directory(path),
    createFile: (path) => memoryFileSystem.file(path),
    getCurrentDirectory: () => memoryFileSystem.currentDirectory,
  );
}
