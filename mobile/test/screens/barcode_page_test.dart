import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/screens/barcode_page.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';

class MockBrightnessService extends Mock implements BrightnessServiceAbstract {}

void main() {
  late MockBrightnessService mockBrightnessService;
  const String testTaxCode = 'RSSMRA80A01H501A';

  setUp(() {
    mockBrightnessService = MockBrightnessService();
    when(
      () => mockBrightnessService.setMaxBrightness(),
    ).thenAnswer((_) async {});
    when(
      () => mockBrightnessService.resetBrightness(),
    ).thenAnswer((_) async {});
  });

  // A helper function to build the BarcodePage with all necessary dependencies.
  // This avoids code duplication in tests.
  Future<void> pumpBarcodePage(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<BrightnessServiceAbstract>.value(
        value: mockBrightnessService,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BarcodePage(taxCode: testTaxCode),
        ),
      ),
    );
  }

  group('BarcodePage', () {
    testWidgets('renders correctly and sets max brightness on init', (
      tester,
    ) async {
      // Act: Build the widget
      await pumpBarcodePage(tester);

      // Assert: Verify UI elements
      expect(find.text('Tax Code Barcode'), findsOneWidget);
      expect(find.byType(BarcodeWidget), findsOneWidget);

      // Assert: Verify the BarcodeWidget receives the correct data
      final barcodeWidget = tester.widget<BarcodeWidget>(
        find.byType(BarcodeWidget),
      );
      expect(barcodeWidget.data, utf8.encode(testTaxCode));

      // Assert: Verify service interactions on initialization
      verify(() => mockBrightnessService.setMaxBrightness()).called(1);
      verifyNever(() => mockBrightnessService.resetBrightness());
    });

    testWidgets('resets brightness on dispose', (tester) async {
      // Arrange: Build the widget first
      await pumpBarcodePage(tester);

      // Verify that setMaxBrightness was called to ensure we are in a valid state
      verify(() => mockBrightnessService.setMaxBrightness()).called(1);

      // Act: Remove the widget from the tree, which triggers dispose()
      await tester.pumpWidget(
        Container(),
      ); // Pumping a different widget removes the old one

      // Assert: Verify service interaction on dispose
      verify(() => mockBrightnessService.resetBrightness()).called(1);
    });
  });
}
