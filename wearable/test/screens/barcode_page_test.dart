import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

void main() {
  late MockNativeViewService mockNativeViewService;

  final testContact = Contact(
    id: 'test-id',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: 'RSSMRA80A01H501U',
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    birthDate: DateTime(1980),
    listIndex: 0,
  );

  Future<void> pumpPage(
    WidgetTester tester, {
    required String taxCode,
    Contact? contact,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Provider<NativeViewServiceAbstract>.value(
          value: mockNativeViewService,
          child: BarcodePage(
            taxCode: taxCode,
            contact: contact,
          ),
        ),
      ),
    );
  }

  setUp(() {
    mockNativeViewService = MockNativeViewService();
    when(
      () => mockNativeViewService.enableHighBrightnessMode(),
    ).thenAnswer((_) async {});
    when(
      () => mockNativeViewService.disableHighBrightnessMode(),
    ).thenAnswer((_) async {});
  });

  group('BarcodePage', () {
    const testTaxCode = 'RSSMRA80A01H501U';

    testWidgets('calls enableHighBrightnessMode on initState', (tester) async {
      await pumpPage(tester, taxCode: testTaxCode);

      verify(() => mockNativeViewService.enableHighBrightnessMode()).called(1);
    });

    testWidgets('renders BarcodeWidget with Code 128 data initially', (tester) async {
      await pumpPage(tester, taxCode: testTaxCode, contact: testContact);

      final barcodeFinder = find.byType(BarcodeWidget);
      expect(barcodeFinder, findsOneWidget);

      final barcodeWidget = tester.widget<BarcodeWidget>(barcodeFinder);
      expect(barcodeWidget.data, utf8.encode(testTaxCode));
      expect(barcodeWidget.barcode.name, 'CODE 128');
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text(testTaxCode), findsOneWidget);
    });

    testWidgets('toggles between Code 128 and QR Code on tap', (tester) async {
      await pumpPage(tester, taxCode: testTaxCode);

      // Initially Code 128
      var barcodeWidget = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodeWidget.barcode.name, 'CODE 128');

      // Tap to toggle
      await tester.tap(find.byType(BarcodeWidget));
      await tester.pumpAndSettle();

      // Now QR Code
      barcodeWidget = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodeWidget.barcode.name, 'QR-Code');

      // Tap again to switch back to Code 128
      await tester.tap(find.byType(BarcodeWidget));
      await tester.pumpAndSettle();

      barcodeWidget = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodeWidget.barcode.name, 'CODE 128');
    });

    testWidgets('calls disableHighBrightnessMode on dispose', (tester) async {
      await pumpPage(tester, taxCode: testTaxCode);

      await tester.pumpWidget(const SizedBox());

      verify(() => mockNativeViewService.disableHighBrightnessMode()).called(1);
    });
  });
}
