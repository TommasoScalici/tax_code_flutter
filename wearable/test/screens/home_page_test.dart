import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

// --- Mocks ---
class MockContactRepository extends Mock implements ContactRepository {}
class MockLogger extends Mock implements Logger {}

void main() {
  late MockContactRepository mockContactRepository;
  late MockLogger mockLogger;

  setUp(() {
    mockContactRepository = MockContactRepository();
    mockLogger = MockLogger();

    when(() => mockContactRepository.isLoading).thenReturn(false);
    when(() => mockContactRepository.contacts).thenReturn([]);
  });

  Widget createTestableWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        Provider<Logger>.value(value: mockLogger),
        ChangeNotifierProvider<ContactRepository>.value(
          value: mockContactRepository,
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('HomePage', () {
    testWidgets('should display a Scaffold and a ContactList',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(child: const HomePage()));

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ContactsList), findsOneWidget);
    });

    testWidgets('should have a black background and correct padding',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(child: const HomePage()));

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);

      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(ContactsList),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(20.0));
    });
  });
}
