import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';

// --- Mocks ---
class MockHomePageController extends Mock implements HomePageController {}

void main() {
  late MockHomePageController mockController;

  // Test data
  final tContact1 = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1980, 1, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  Future<void> pumpWidget(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<HomePageController>.value(
        value: mockController,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ContactsList(cardHeight: 300)),
        ),
      ),
    );
  }

  setUp(() {
    mockController = MockHomePageController();
    registerFallbackValue(Contact.empty());
  });

  group('ContactsList', () {
    testWidgets('displays a CircularProgressIndicator when isLoading is true', (
      tester,
    ) async {
      // Arrange
      when(() => mockController.isLoading).thenReturn(true);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'displays empty list message when contactsToShow is empty and no search text',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.contactsToShow).thenReturn([]);
        when(() => mockController.searchText).thenReturn('');

        // Act
        await pumpWidget(tester);

        // Assert
        expect(
          find.text(
            "No contacts yet.\nTap the '+' button to add your first one!",
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays no results message when contactsToShow is empty and there is search text',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.contactsToShow).thenReturn([]);
        when(() => mockController.searchText).thenReturn('Luigi');

        // Act
        await pumpWidget(tester);

        // Assert
        expect(find.text("No results found for 'Luigi'"), findsOneWidget);
      },
    );

    testWidgets(
      'displays a list of ContactCards when contactsToShow is not empty',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.contactsToShow).thenReturn([tContact1]);
        when(() => mockController.searchText).thenReturn('');
        when(() => mockController.isReorderable).thenReturn(false);

        // Act
        await pumpWidget(tester);

        // Assert
        expect(find.byType(ContactCard), findsOneWidget);
        expect(find.text(tContact1.taxCode), findsOneWidget);
      },
    );

    testWidgets(
      'calls filterContacts on controller when text is entered in search field',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.contactsToShow).thenReturn([]);
        when(() => mockController.searchText).thenReturn('');
        when(() => mockController.filterContacts(any())).thenReturn(null);

        // Act
        await pumpWidget(tester);
        await tester.enterText(find.byType(TextField), 'Mario');

        // Assert
        verify(() => mockController.filterContacts('Mario')).called(1);
      },
    );

    testWidgets(
      'calls filterContacts and clears text when clear button is tapped',
      (tester) async {
        // Arrange
        when(() => mockController.isLoading).thenReturn(false);
        when(() => mockController.contactsToShow).thenReturn([]);
        when(() => mockController.searchText).thenReturn('Mario');
        when(() => mockController.filterContacts(any())).thenReturn(null);

        // Act
        await pumpWidget(tester);

        final clearButtonFinder = find.widgetWithIcon(IconButton, Icons.clear);
        expect(clearButtonFinder, findsOneWidget);

        final iconButton = tester.widget<IconButton>(clearButtonFinder);

        expect(iconButton.onPressed, isNotNull);
        iconButton.onPressed!();

        await tester.pump();

        // Assert
        verify(() => mockController.filterContacts('')).called(1);
      },
    );

    testWidgets('calls deleteContact on controller after confirming dialog', (
      tester,
    ) async {
      // Arrange
      when(() => mockController.isLoading).thenReturn(false);
      when(() => mockController.contactsToShow).thenReturn([tContact1]);
      when(() => mockController.searchText).thenReturn('');
      when(() => mockController.isReorderable).thenReturn(false);
      when(() => mockController.deleteContact(any())).thenAnswer((_) async {});

      // Act
      await pumpWidget(tester);
      // Tap the delete icon inside the card.
      await tester.tap(find.byIcon(Icons.delete));
      // Wait for the dialog to appear.
      await tester.pumpAndSettle();

      // Verify the dialog is shown.
      expect(find.text('Confirm Deletion'), findsOneWidget);

      // Tap the 'Delete' button in the dialog.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      // Verify that the controller method was called with the correct contact.
      verify(() => mockController.deleteContact(tContact1)).called(1);
    });
  });
}
