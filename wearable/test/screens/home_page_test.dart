import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

//--- Mock ---//
class MockContactsListController extends Mock
    implements ContactsListController {}

void main() {
  late MockContactsListController mockController;

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<ContactsListController>.value(
          value: mockController,
          child: const HomePage(),
        ),
      ),
    );
  }

  setUp(() {
    mockController = MockContactsListController();

    when(() => mockController.addListener(any())).thenAnswer((_) {});
    when(() => mockController.removeListener(any())).thenAnswer((_) {});
    when(() => mockController.isLoading).thenReturn(false);
    when(() => mockController.hasContacts).thenReturn(false);
    when(() => mockController.isLaunchingPhoneApp).thenReturn(false);
  });

  group('HomePage Widget', () {
    testWidgets('renders its structure and child widgets correctly', (
      tester,
    ) async {
      // Act
      await pumpWidget(tester);

      // Assert
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final paddingFinder = find.ancestor(
        of: find.byType(ContactsList),
        matching: find.byType(Padding),
      );
      expect(paddingFinder, findsOneWidget);

      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect(paddingWidget.padding, const EdgeInsets.all(20.0));

      final contactsListFinder = find.descendant(
        of: paddingFinder,
        matching: find.byType(ContactsList),
      );
      expect(contactsListFinder, findsOneWidget);
    });
  });
}
