import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';

// --- Mocks ---
class MockVoidCallback extends Mock {
  void call();
}

void main() {
  const tBirthplace = Birthplace(name: 'Roma', state: 'RM');
  final tContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1980, 1, 15),
    birthPlace: tBirthplace,
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    required VoidCallback onShare,
    required VoidCallback onShowBarcode,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    VoidCallback? onCopy,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ContactCard(
            contact: tContact,
            onShare: onShare,
            onShowBarcode: onShowBarcode,
            onEdit: onEdit,
            onDelete: onDelete,
            onCopy: onCopy,
          ),
        ),
      ),
    );
  }

  group('ContactCard', () {
    late MockVoidCallback mockOnShare;
    late MockVoidCallback mockOnShowBarcode;
    late MockVoidCallback mockOnEdit;
    late MockVoidCallback mockOnDelete;

    setUp(() {
      mockOnShare = MockVoidCallback();
      mockOnShowBarcode = MockVoidCallback();
      mockOnEdit = MockVoidCallback();
      mockOnDelete = MockVoidCallback();
    });

    testWidgets('should display all contact information correctly', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        onShare: mockOnShare.call,
        onShowBarcode: mockOnShowBarcode.call,
        onEdit: mockOnEdit.call,
        onDelete: mockOnDelete.call,
      );

      expect(find.text(tContact.taxCode), findsOneWidget);
      expect(find.text(tContact.firstName), findsOneWidget);
      expect(find.text(tContact.lastName), findsOneWidget);
      expect(find.text(tContact.gender), findsOneWidget);
      expect(find.text('1/15/1980'), findsOneWidget);
      expect(find.text(tBirthplace.toString()), findsOneWidget);
      expect(find.byIcon(Icons.drag_indicator_rounded), findsOneWidget);
    });

    testWidgets('should call onShare when the share button is tapped', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        onShare: mockOnShare.call,
        onShowBarcode: mockOnShowBarcode.call,
        onEdit: mockOnEdit.call,
        onDelete: mockOnDelete.call,
      );
      await tester.tap(find.byIcon(Icons.share));
      verify(() => mockOnShare()).called(1);
    });

    testWidgets('should call onShowBarcode when the barcode button is tapped', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        onShare: mockOnShare.call,
        onShowBarcode: mockOnShowBarcode.call,
        onEdit: mockOnEdit.call,
        onDelete: mockOnDelete.call,
      );
      await tester.tap(find.byIcon(Symbols.barcode));
      verify(() => mockOnShowBarcode()).called(1);
    });

    testWidgets('should call onEdit when the edit button is tapped', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        onShare: mockOnShare.call,
        onShowBarcode: mockOnShowBarcode.call,
        onEdit: mockOnEdit.call,
        onDelete: mockOnDelete.call,
      );
      await tester.tap(find.byIcon(Icons.edit));
      verify(() => mockOnEdit()).called(1);
    });

    testWidgets('should call onDelete when the delete button is tapped', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        onShare: mockOnShare.call,
        onShowBarcode: mockOnShowBarcode.call,
        onEdit: mockOnEdit.call,
        onDelete: mockOnDelete.call,
      );
      await tester.tap(find.byIcon(Icons.delete));
      verify(() => mockOnDelete()).called(1);
    });

    testWidgets(
      'should call onCopy and show snackbar when tax code box is tapped',
      (tester) async {
        var copyCalled = false;
        await pumpWidget(
          tester,
          onShare: mockOnShare.call,
          onShowBarcode: mockOnShowBarcode.call,
          onEdit: mockOnEdit.call,
          onDelete: mockOnDelete.call,
          onCopy: () => copyCalled = true,
        );

        final taxCodeBox = find.byKey(const Key('contact_card_tax_code_box'));
        expect(taxCodeBox, findsOneWidget);

        await tester.tap(taxCodeBox);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(copyCalled, isTrue);
        expect(find.text('Tax code copied to clipboard'), findsOneWidget);
      },
    );

    testWidgets(
      'ContactCardHeader displays avatar, names, gender and drag indicator',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactCardHeader(contact: tContact)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
        expect(find.text('Mario'), findsOneWidget);
        expect(find.text('Rossi'), findsOneWidget);
        expect(find.text('M'), findsOneWidget);
        expect(find.byIcon(Icons.drag_indicator_rounded), findsOneWidget);
      },
    );

    testWidgets('ContactCardTaxCodeBox renders tax code and triggers onTap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: Scaffold(
            body: ContactCardTaxCodeBox(
              taxCode: 'RSSMRA80A15H501U',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RSSMRA80A15H501U'), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('contact_card_tax_code_box')));
      expect(tapped, isTrue);
    });

    testWidgets(
      'ContactCardAnagraphics displays birthplace and formatted birthdate',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates:
                AppLocalizationsSetup.localizationsDelegates,
            home: Scaffold(
              body: ContactCardAnagraphics(
                birthPlace: tBirthplace,
                birthDate: DateTime(1980, 1, 15),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(tBirthplace.toString()), findsOneWidget);
        expect(find.text('1/15/1980'), findsOneWidget);
        expect(find.byIcon(Icons.place_outlined), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'ContactCardActionButtons triggers callbacks for all 4 actions',
      (tester) async {
        var shareTapped = false;
        var barcodeTapped = false;
        var editTapped = false;
        var deleteTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates:
                AppLocalizationsSetup.localizationsDelegates,
            home: Scaffold(
              body: ContactCardActionButtons(
                onShare: () => shareTapped = true,
                onShowBarcode: () => barcodeTapped = true,
                onEdit: () => editTapped = true,
                onDelete: () => deleteTapped = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.share));
        expect(shareTapped, isTrue);

        await tester.tap(find.byIcon(Symbols.barcode));
        expect(barcodeTapped, isTrue);

        await tester.tap(find.byIcon(Icons.edit));
        expect(editTapped, isTrue);

        await tester.tap(find.byIcon(Icons.delete));
        expect(deleteTapped, isTrue);
      },
    );
  });
}
