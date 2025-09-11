import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ContactCard(
            contact: tContact,
            onShare: onShare,
            onShowBarcode: onShowBarcode,
            onEdit: onEdit,
            onDelete: onDelete,
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
  });
}
