import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

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
    when(() => mockController.isDemoMode).thenReturn(false);
    when(() => mockController.isLaunchingPhoneApp).thenReturn(false);
  });

  group('HomePage Widget', () {
    testWidgets('renders Scaffold and child ContactsList', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ContactsList), findsOneWidget);
    });
  });
}
