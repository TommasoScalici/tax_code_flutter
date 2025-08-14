import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';

class MockScreenBrightnessPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ScreenBrightnessPlatform {}

void main() {
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
    testWidgets('should set brightness on initState and reset on dispose',
        (WidgetTester tester) async {
      // Arrange
      
      // Act
      await tester.pumpWidget(const MaterialApp(
        home: BarcodePage(taxCode: 'TESTCODE'),
      ));

      // Assert
      verify(() => mockPlatform.setApplicationScreenBrightness(1.0)).called(1);

      // Act
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Assert
      verify(() => mockPlatform.resetApplicationScreenBrightness()).called(1);
    });

    testWidgets('should display BarcodeWidget with correct data and properties',
        (WidgetTester tester) async {
      // Arrange
      const testTaxCode = 'RSSMRA80A01H501U';

      await tester.pumpWidget(const MaterialApp(
        home: BarcodePage(taxCode: testTaxCode),
      ));

      // Assert
      final barcodeWidgetFinder = find.byType(BarcodeWidget);
      expect(barcodeWidgetFinder, findsOneWidget);

      final barcodeWidget = tester.widget<BarcodeWidget>(barcodeWidgetFinder);
      expect(barcodeWidget.data, utf8.encode(testTaxCode));
      expect(barcodeWidget.barcode.name, 'CODE 39');
    });
  });
}