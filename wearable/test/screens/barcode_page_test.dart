import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations_en.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/brightness_service.dart';

class MockBrightnessService extends Mock implements BrightnessServiceAbstract {}

void main() {
  late MockBrightnessService mockBrightnessService;

  Widget createTestableWidget(String taxCode) {
    return Provider<BrightnessServiceAbstract>.value(
      value: mockBrightnessService,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BarcodePage(taxCode: taxCode),
      ),
    );
  }
  
  setUp(() {
    mockBrightnessService = MockBrightnessService();
    when(() => mockBrightnessService.setMaxBrightness()).thenAnswer((_) async {});
    when(() => mockBrightnessService.resetBrightness()).thenAnswer((_) async {});
  });

  group('BarcodePage', () {
    testWidgets('should call BrightnessService on lifecycle events', (tester) async {
      await tester.pumpWidget(createTestableWidget('TESTCODE'));
      verify(() => mockBrightnessService.setMaxBrightness()).called(1);

      await tester.pumpWidget(const SizedBox.shrink());
      verify(() => mockBrightnessService.resetBrightness()).called(1);
    });

    testWidgets('should display AppBar and BarcodeWidget correctly', (tester) async {
      const testTaxCode = 'RSSMRA80A01H501U';
      await tester.pumpWidget(createTestableWidget(testTaxCode));

      // Assert UI
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(AppLocalizationsEn().barcodePageTitle), findsOneWidget);

      final barcodeWidgetFinder = find.byType(BarcodeWidget);
      expect(barcodeWidgetFinder, findsOneWidget);

      final barcodeWidget = tester.widget<BarcodeWidget>(barcodeWidgetFinder);
      
      expect(barcodeWidget.data, utf8.encode(testTaxCode));
      expect(barcodeWidget.barcode.name, 'CODE 39');
    });
  });
}