import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';
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
  });

  group('ContactsList Widget', () {
    testWidgets(
      'displays CircularProgressIndicator when controller is loading',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(true);
        when(() => mockController.hasContacts).thenReturn(false);
        when(() => mockController.isLaunchingPhoneApp).thenReturn(false);

        // Act
        await pumpWidget(tester);

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets('displays SizedBox.shrink when controller has contacts', (
      tester,
    ) async {
      // Arrange
      when(() => mockController.isLoading).thenReturn(false);
      when(() => mockController.hasContacts).thenReturn(true);
      when(() => mockController.isLaunchingPhoneApp).thenReturn(false);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets(
      'displays empty state message and button when there are no contacts',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.hasContacts).thenReturn(false);
        when(() => mockController.isLaunchingPhoneApp).thenReturn(false);

        // Act
        await pumpWidget(tester);

        // Assert
        expect(
          find.text('No contacts found. Add them on your phone.'),
          findsOneWidget,
        );

        expect(find.text('Open on phone'), findsOneWidget);
        expect(find.byIcon(Icons.phone_android), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'displays loading indicator instead of button when launching phone app',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.hasContacts).thenReturn(false);
        when(() => mockController.isLaunchingPhoneApp).thenReturn(true);

        // Act
        await pumpWidget(tester);

        // Assert
        expect(
          find.text('No contacts found. Add them on your phone.'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 3);

        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets('calls launchPhoneApp on controller when button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockController.isLoading).thenReturn(false);
      when(() => mockController.hasContacts).thenReturn(false);
      when(() => mockController.isLaunchingPhoneApp).thenReturn(false);
      when(() => mockController.launchPhoneApp()).thenAnswer((_) async {});
      await pumpWidget(tester);

      // Act
      await tester.tap(find.text('Open on phone'));
      await tester.pump();

      // Assert
      verify(() => mockController.launchPhoneApp()).called(1);
    });
  });
}
