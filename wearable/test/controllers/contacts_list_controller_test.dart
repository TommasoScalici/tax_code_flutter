import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class MockContactRepository extends Mock implements ContactRepository {}

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

class MockLogger extends Mock implements Logger {}

void main() {
  late ContactsListController controller;
  late MockContactRepository mockContactRepository;
  late MockNativeViewService mockNativeViewService;
  late MockLogger mockLogger;

  late VoidCallback onContactsChangedCallback;

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
    when(() => mockNativeViewService.launchPhoneApp()).thenAnswer((_) async {});

    when(() => mockContactRepository.addListener(any())).thenAnswer((
      invocation,
    ) {
      onContactsChangedCallback =
          invocation.positionalArguments.first as VoidCallback;
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

      test('correctly exposes repository properties', () {
        final contacts = createRealContacts(2);
        when(() => mockContactRepository.contacts).thenReturn(contacts);
        when(() => mockContactRepository.isLoading).thenReturn(true);

        expect(controller.contacts, contacts);
        expect(controller.hasContacts, isTrue);
        expect(controller.isLoading, isTrue);
      });
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
          verifyNever(() => mockLogger.e(any<Object?>()));
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
            any<Object?>(),
            error: exception,
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    group('Repository Updates', () {
      test('notifies listeners when repository contacts change', () {
        int notifyCallCount = 0;
        controller.addListener(() => notifyCallCount++);

        onContactsChangedCallback();

        expect(notifyCallCount, 1);
      });
    });

    test('dispose removes listener from ContactRepository', () {
      controller.dispose();
      verify(
        () => mockContactRepository.removeListener(onContactsChangedCallback),
      ).called(1);
    });
  });
}
