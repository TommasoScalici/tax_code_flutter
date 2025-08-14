import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

import '../fakes/fake_contact_repository.dart';

/// Mocks
class MockLogger extends Mock implements Logger {}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final List<MethodCall> log = <MethodCall>[];
  const channel =
      MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  late FakeContactRepository fakeContactRepository;
  late MockLogger mockLogger;

  Widget createTestableWidget() {
    return MultiProvider(
      providers: [
        Provider<Logger>.value(value: mockLogger),
        ChangeNotifierProvider<ContactRepository>.value(
          value: fakeContactRepository,
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ContactsList()),
      ),
    );
  }

  setUp(() {
    fakeContactRepository = FakeContactRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.i(any())).thenAnswer((_) {});
    when(() => mockLogger.e(any())).thenAnswer((_) {});

    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });
    log.clear();
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('ContactsList', () {
    testWidgets('should display CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      fakeContactRepository.setState(loading: true);
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should invoke native method when contacts are available',
        (WidgetTester tester) async {
      final testContact = Contact.empty().copyWith(id: '1');
      await tester.pumpWidget(createTestableWidget());
      fakeContactRepository.setState(newContacts: [testContact]);
      await tester.pumpAndSettle();

      expect(log, hasLength(1));
      expect(log.first.method, 'openNativeContactList');
      final contactsData =
          (log.first.arguments as Map)['contacts'] as List<dynamic>;
      expect(contactsData.first['id'], '1');
    });

    testWidgets(
        'should NOT invoke native method again on rebuild if already shown',
        (WidgetTester tester) async {
      final testContact = Contact.empty().copyWith(id: '1');
      fakeContactRepository.setState(newContacts: [testContact]);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(log, hasLength(1));
      
      await tester.pump();
      expect(log, hasLength(1));
    });

    testWidgets(
        'should allow showing native view again after contacts are cleared and reloaded',
        (WidgetTester tester) async {
      final testContact = Contact.empty().copyWith(id: '1');
      await tester.pumpWidget(createTestableWidget());
      
      fakeContactRepository.setState(newContacts: [testContact]);
      await tester.pumpAndSettle();
      expect(log, hasLength(1), reason: 'Should be called on first login');

      fakeContactRepository.setState(newContacts: []);
      await tester.pump();
      expect(log, hasLength(1), reason: 'Should not be called on logout');

      fakeContactRepository.setState(newContacts: [testContact]);
      await tester.pumpAndSettle();

      expect(log, hasLength(2),
          reason: 'Should be called again on second login');
    });

    testWidgets('should log an error when native method fails',
        (WidgetTester tester) async {
      // Arrange
      final testContact = Contact.empty().copyWith(id: '1');
      final exception = PlatformException(code: 'ERROR', message: 'Failed');

      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        throw exception;
      });

      fakeContactRepository.setState(newContacts: [testContact]);

      // Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockLogger.e("Failed to invoke native method: '${exception.message}'."))
          .called(1);
    });
  });
}