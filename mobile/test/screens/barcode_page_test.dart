import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';
import 'package:tax_code_flutter/screens/barcode_page.dart';


class MockScreenBrightnessPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ScreenBrightnessPlatform {}

void main() {
  const fakeTaxCode = 'RSSMRA80A01H501A';
  late MockScreenBrightnessPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockScreenBrightnessPlatform();
    ScreenBrightnessPlatform.instance = mockPlatform;

    when(() => mockPlatform.setApplicationScreenBrightness(any()))
        .thenAnswer((_) async {});
    when(() => mockPlatform.resetApplicationScreenBrightness())
        .thenAnswer((_) async {});
  });

  group('BarcodePage', () {
    testWidgets('renders correctly and sets brightness on build',
        (tester) async {
      // ACT
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BarcodePage(taxCode: fakeTaxCode),
      ));

      // ASSERT - UI
      final barcodeFinder = find.byType(BarcodeWidget);
      expect(barcodeFinder, findsOneWidget);

      final barcodeWidget = tester.widget<BarcodeWidget>(barcodeFinder);
      expect(barcodeWidget.data, utf8.encode(fakeTaxCode));
      expect(barcodeWidget.barcode.name, 'CODE 39');

      // ASSERT - Side Effects
      verify(() => mockPlatform.setApplicationScreenBrightness(1.0)).called(1);
    });

    testWidgets('resets brightness when popped via Navigator', (tester) async {
      // ARRANGE
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BarcodePage(taxCode: fakeTaxCode),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      // ACT 1
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(BarcodePage), findsOneWidget);
      verify(() => mockPlatform.setApplicationScreenBrightness(1.0)).called(1);

      // ACT 2
      await tester.pageBack();
      await tester.pumpAndSettle();

      // ASSERT
      verify(() => mockPlatform.resetApplicationScreenBrightness()).called(1);
      expect(find.byType(BarcodePage), findsNothing);
    });
  });
}