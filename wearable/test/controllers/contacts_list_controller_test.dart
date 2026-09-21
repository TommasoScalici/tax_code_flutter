import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class MockContactRepository extends Mock implements ContactRepository {}

class MockDemoModeService extends Mock implements DemoModeServiceAbstract {}

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

class MockLogger extends Mock implements Logger {}

void main() {
  late ContactsListController controller;
  late MockContactRepository mockContactRepository;
  late MockDemoModeService mockDemoModeService;
  late MockNativeViewService mockNativeViewService;
  late MockLogger mockLogger;

  late VoidCallback onContactsChangedCallback;
  late VoidCallback onDemoModeChangedCallback;

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
    mockDemoModeService = MockDemoModeService();
    mockNativeViewService = MockNativeViewService();
    mockLogger = MockLogger();

    when(() => mockContactRepository.contacts).thenReturn([]);
    when(() => mockContactRepository.isLoading).thenReturn(false);
    when(() => mockNativeViewService.launchPhoneApp()).thenAnswer((_) async {});

    when(() => mockDemoModeService.isDemoMode).thenReturn(false);
    when(() => mockDemoModeService.demoContacts).thenReturn([]);

    when(() => mockContactRepository.addListener(any())).thenAnswer((
      invocation,
    ) {
      onContactsChangedCallback =
          invocation.positionalArguments.first as VoidCallback;
    });

    when(() => mockContactRepository.removeListener(any())).thenAnswer((_) {});

    when(() => mockDemoModeService.addListener(any())).thenAnswer((
      invocation,
    ) {
      onDemoModeChangedCallback =
          invocation.positionalArguments.first as VoidCallback;
    });

    when(() => mockDemoModeService.removeListener(any())).thenAnswer((_) {});

    controller = ContactsListController(
      contactRepository: mockContactRepository,
      demoModeService: mockDemoModeService,
      nativeViewService: mockNativeViewService,
      logger: mockLogger,
    );
  });

  group('ContactsListController', () {
    group('Initialization', () {
      test('adds listener to ContactRepository and DemoModeService on creation', () {
        verify(() => mockContactRepository.addListener(any())).called(1);
        verify(() => mockDemoModeService.addListener(any())).called(1);
      });

      test('correctly exposes repository properties when not in demo mode', () {
        final contacts = createRealContacts(2);
        when(() => mockContactRepository.contacts).thenReturn(contacts);
        when(() => mockContactRepository.isLoading).thenReturn(true);

        expect(controller.isDemoMode, isFalse);
        expect(controller.contacts, contacts);
        expect(controller.hasContacts, isTrue);
        expect(controller.isLoading, isTrue);
      });

      test('correctly exposes demo properties when in demo mode', () {
        final demoContacts = createRealContacts(3);
        when(() => mockDemoModeService.isDemoMode).thenReturn(true);
        when(() => mockDemoModeService.demoContacts).thenReturn(demoContacts);

        expect(controller.isDemoMode, isTrue);
        expect(controller.contacts, demoContacts);
        expect(controller.hasContacts, isTrue);
        expect(controller.isLoading, isFalse);
      });
    });

    group('launchPhoneApp', () {
      test(
        'sets loading state, calls service, and resets on success',
        () async {
          var notifyCallCount = 0;
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
        var notifyCallCount = 0;
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

    group('Demo Mode Operations', () {
      test('exitDemoMode calls service exitDemoMode', () {
        when(() => mockDemoModeService.exitDemoMode()).thenReturn(null);

        controller.exitDemoMode();

        verify(() => mockDemoModeService.exitDemoMode()).called(1);
      });

      test('notifies listeners when demo mode state changes', () {
        var notifyCallCount = 0;
        controller.addListener(() => notifyCallCount++);

        onDemoModeChangedCallback();

        expect(notifyCallCount, 1);
      });
    });

    group('Repository Updates', () {
      test('notifies listeners when repository contacts change', () {
        var notifyCallCount = 0;
        controller.addListener(() => notifyCallCount++);

        onContactsChangedCallback();

        expect(notifyCallCount, 1);
      });
    });

    test('dispose removes listener from ContactRepository and DemoModeService', () {
      controller.dispose();
      verify(
        () => mockContactRepository.removeListener(onContactsChangedCallback),
      ).called(1);
      verify(
        () => mockDemoModeService.removeListener(onDemoModeChangedCallback),
      ).called(1);
    });
  });
}
