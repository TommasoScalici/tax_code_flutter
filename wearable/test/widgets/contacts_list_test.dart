import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contact_card.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

class MockContactsListController extends Mock
    implements ContactsListController {}

void main() {
  late MockContactsListController mockController;

  final testContacts = [
    Contact(
      id: 'id-1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01H501U',
      birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
      birthDate: DateTime(1980),
      listIndex: 0,
    ),
  ];

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: Settings.getWearTheme(),
        home: Scaffold(
          body: ChangeNotifierProvider<ContactsListController>.value(
            value: mockController,
            child: const ContactsList(),
          ),
        ),
      ),
    );
  }

  setUp(() {
    mockController = MockContactsListController();
    when(() => mockController.contacts).thenReturn([]);
    when(() => mockController.isLoading).thenReturn(false);
    when(() => mockController.hasContacts).thenReturn(false);
    when(() => mockController.isLaunchingPhoneApp).thenReturn(false);
    when(() => mockController.launchPhoneApp()).thenAnswer((_) async {});
  });

  group('ContactsList Widget', () {
    testWidgets(
      'displays CircularProgressIndicator when controller is loading',
      (tester) async {
        when(() => mockController.isLoading).thenReturn(true);

        await pumpWidget(tester);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets('displays ListView with WearContactCard and WearTimeHeader when controller has contacts', (
      tester,
    ) async {
      when(() => mockController.hasContacts).thenReturn(true);
      when(() => mockController.contacts).thenReturn(testContacts);

      await pumpWidget(tester);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(WearTimeHeader), findsOneWidget);
      expect(find.byType(WearContactCard), findsOneWidget);
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('RSSMRA80A01H501U'), findsOneWidget);
    });

    testWidgets(
      'displays empty state message and button when there are no contacts',
      (tester) async {
        await pumpWidget(tester);

        expect(
          find.text('No contacts found. Add them on your phone.'),
          findsOneWidget,
        );
        expect(find.text('Open on phone'), findsOneWidget);
        expect(find.byIcon(Icons.phone_android), findsOneWidget);
        expect(find.byType(WearTimeHeader), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'displays loading indicator instead of button when launching phone app',
      (tester) async {
        when(() => mockController.isLaunchingPhoneApp).thenReturn(true);

        await pumpWidget(tester);

        expect(
          find.text('No contacts found. Add them on your phone.'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('calls launchPhoneApp on controller when button is tapped', (
      tester,
    ) async {
      await pumpWidget(tester);

      await tester.tap(find.text('Open on phone'));
      await tester.pump();

      verify(() => mockController.launchPhoneApp()).called(1);
    });

    testWidgets(
      'renders sign out confirmation dialog without overflow on 192x192 dp',
      (tester) async {
        tester.view.physicalSize = const Size(384, 384);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await pumpWidget(tester);

        // Find and tap Sign out button
        final signOutButton = find.text('Sign out');
        expect(signOutButton, findsOneWidget);
        await tester.ensureVisible(signOutButton);
        await tester.pumpAndSettle();
        await tester.tap(signOutButton);
        await tester.pumpAndSettle();

        // Verify dialog is shown without any overflow
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Dismiss dialog
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });
}
