import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

//--- Mock ---//
class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

void main() {
  late MockNativeViewService mockNativeViewService;

  Future<void> pumpPage(WidgetTester tester, {required String taxCode}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<NativeViewServiceAbstract>.value(
          value: mockNativeViewService,
          child: BarcodePage(taxCode: taxCode),
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
      // Act
      await pumpPage(tester, taxCode: testTaxCode);

      // Assert
      verify(() => mockNativeViewService.enableHighBrightnessMode()).called(1);
    });

    testWidgets('renders BarcodeWidget with correct data', (tester) async {
      // Act
      await pumpPage(tester, taxCode: testTaxCode);

      // Assert
      final barcodeWidgetFinder = find.byType(BarcodeWidget);
      expect(barcodeWidgetFinder, findsOneWidget);

      final barcodeWidget = tester.widget<BarcodeWidget>(barcodeWidgetFinder);
      expect(barcodeWidget.data, utf8.encode(testTaxCode));
      expect(barcodeWidget.barcode.name, 'CODE 39');
    });

    testWidgets('calls disableHighBrightnessMode on dispose', (tester) async {
      // Arrange
      await pumpPage(tester, taxCode: testTaxCode);

      // Act
      await tester.pumpWidget(const SizedBox());

      // Assert
      verify(() => mockNativeViewService.disableHighBrightnessMode()).called(1);
    });
  });
}
