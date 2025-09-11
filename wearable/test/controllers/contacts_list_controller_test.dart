import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

//--- Mocks ---//

class MockContactRepository extends Mock implements ContactRepository {}

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

class MockLogger extends Mock implements Logger {}

void main() {
  late ContactsListController controller;
  late MockContactRepository mockContactRepository;
  late MockNativeViewService mockNativeViewService;
  late MockLogger mockLogger;

  late VoidCallback onContactsChangedCallback;

  // Funzione helper per creare una lista di istanze REALI di Contact
  List<Contact> createRealContacts(int count) {
    return List.generate(
      count,
      (i) => Contact(
        id: 'id_$i',
        firstName: 'Nome_$i',
        lastName: 'Cognome_$i',
        gender: 'M',
        taxCode: 'ABC...',
        birthPlace: const Birthplace(name: 'Comune', state: 'PR'),
        birthDate: DateTime.now(),
        listIndex: i,
      ),
    );
  }

  setUp(() {
    mockContactRepository = MockContactRepository();
    mockNativeViewService = MockNativeViewService();
    mockLogger = MockLogger();

    when(() => mockContactRepository.contacts).thenReturn([]);
    when(() => mockContactRepository.isLoading).thenReturn(false);
    when(
      () => mockNativeViewService.showContactList(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNativeViewService.updateContactList(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNativeViewService.closeContactList(),
    ).thenAnswer((_) async {});
    when(() => mockNativeViewService.launchPhoneApp()).thenAnswer((_) async {});

    when(() => mockContactRepository.addListener(any())).thenAnswer((
      invocation,
    ) {
      onContactsChangedCallback = invocation.positionalArguments.first;
    });

    when(() => mockContactRepository.removeListener(any())).thenAnswer((_) {});

    controller = ContactsListController(
      contactRepository: mockContactRepository,
      nativeViewService: mockNativeViewService,
      logger: mockLogger,
    );
  });

  group('ContactsListController', () {
    group('Initialization', () {
      test('adds listener to ContactRepository on creation', () {
        verify(() => mockContactRepository.addListener(any())).called(1);
      });

      test('calls showContactList if repository has contacts initially', () {
        // Arrange
        final initialContacts = createRealContacts(2);
        when(() => mockContactRepository.contacts).thenReturn(initialContacts);

        // Act: La semplice creazione del controller è l'azione da testare
        ContactsListController(
          contactRepository: mockContactRepository,
          nativeViewService: mockNativeViewService,
          logger: mockLogger,
        );

        // Assert
        verify(
          () => mockNativeViewService.showContactList(initialContacts),
        ).called(1);
      });

      test(
        'does NOT call showContactList if repository is empty initially',
        () {
          verifyNever(() => mockNativeViewService.showContactList(any()));
        },
      );
    });

    group('launchPhoneApp', () {
      test(
        'sets loading state, calls service, and resets on success',
        () async {
          int notifyCallCount = 0;
          controller.addListener(() => notifyCallCount++);

          final future = controller.launchPhoneApp();

          expect(controller.isLaunchingPhoneApp, isTrue);
          expect(notifyCallCount, 1);

          await future;

          expect(controller.isLaunchingPhoneApp, isFalse);
          expect(notifyCallCount, 2);
          verify(() => mockNativeViewService.launchPhoneApp()).called(1);
          verifyNever(() => mockLogger.e(any()));
        },
      );

      test('resets loading state and logs error on failure', () async {
        final exception = Exception('Failed to launch');
        when(() => mockNativeViewService.launchPhoneApp()).thenThrow(exception);
        int notifyCallCount = 0;
        controller.addListener(() => notifyCallCount++);

        await controller.launchPhoneApp();

        expect(controller.isLaunchingPhoneApp, isFalse);
        expect(notifyCallCount, 2);
        verify(
          () => mockLogger.e(
            any(),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    group('Repository Updates (_onContactsChanged)', () {
      test(
        'calls showContactList when contacts are added for the first time',
        () {
          final newContacts = createRealContacts(1);
          when(() => mockContactRepository.contacts).thenReturn(newContacts);

          onContactsChangedCallback();

          verify(
            () => mockNativeViewService.showContactList(newContacts),
          ).called(1);
        },
      );

      test(
        'calls updateContactList when contacts change and view is already active',
        () {
          final initialContacts = createRealContacts(1);
          when(
            () => mockContactRepository.contacts,
          ).thenReturn(initialContacts);
          onContactsChangedCallback();
          verify(
            () => mockNativeViewService.showContactList(initialContacts),
          ).called(1);

          final updatedContacts = createRealContacts(2);
          when(
            () => mockContactRepository.contacts,
          ).thenReturn(updatedContacts);

          onContactsChangedCallback();

          verify(
            () => mockNativeViewService.updateContactList(updatedContacts),
          ).called(1);
          verifyNever(
            () => mockNativeViewService.showContactList(updatedContacts),
          );
        },
      );

      test('calls closeContactList when all contacts are removed', () {
        final initialContacts = createRealContacts(1);
        when(() => mockContactRepository.contacts).thenReturn(initialContacts);
        onContactsChangedCallback();

        when(() => mockContactRepository.contacts).thenReturn([]);

        onContactsChangedCallback();

        verify(() => mockNativeViewService.closeContactList()).called(1);
      });
    });

    group('dispose', () {
      test('removes listener from ContactRepository on dispose', () {
        controller.dispose();

        verify(() => mockContactRepository.removeListener(any())).called(1);
      });
    });
  });
}
