import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';

import '../helpers/mocks.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(setupTests);

  late MockBrightnessService mockBrightnessService;

  final testContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1985, 4, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA85D15H501Z',
    listIndex: 0,
  );

  setUp(() {
    mockBrightnessService = MockBrightnessService();
    when(() => mockBrightnessService.setMaxBrightness())
        .thenAnswer((_) async {});
    when(() => mockBrightnessService.resetBrightness())
        .thenAnswer((_) async {});
  });

  Widget buildTestApp({
    required Widget child,
    Locale locale = const Locale('it'),
  }) {
    return Provider<BrightnessServiceAbstract>.value(
      value: mockBrightnessService,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('BarcodeBottomSheet Widget Tests', () {
    testWidgets('renders contact name, tax code and labels in Italian', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: BarcodeBottomSheet(
            contact: testContact,
            brightnessService: mockBrightnessService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('RSSMRA85D15H501Z'), findsNWidgets(2)); // Chip and barcode text
      expect(find.text('CODICE A BARRE (CODE 128)'), findsOneWidget);
      expect(find.text('OPPURE'), findsOneWidget);
      expect(find.text('QR Code Sanitario'), findsOneWidget);
      expect(
        find.text('Mostra allo sportello farmaceutico o sanitario'),
        findsOneWidget,
      );
      expect(
        find.text('Luminosità massima attiva per lettura ottica'),
        findsOneWidget,
      );
      expect(find.text('Chiudi'), findsOneWidget);
      expect(find.text('Copia'), findsOneWidget);

      // Verify barcode widgets
      final barcodes = tester.widgetList<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodes.length, 2);
      expect(
        barcodes.first.data,
        anyOf('RSSMRA85D15H501Z', 'RSSMRA85D15H501Z'.codeUnits),
      );
      expect(
        barcodes.last.data,
        anyOf('RSSMRA85D15H501Z', 'RSSMRA85D15H501Z'.codeUnits),
      );
    });

    testWidgets('renders labels in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: BarcodeBottomSheet(
            contact: testContact,
            brightnessService: mockBrightnessService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BARCODE (CODE 128)'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
      expect(find.text('Health QR Code'), findsOneWidget);
      expect(
        find.text('Maximum brightness active for optical scanning'),
        findsOneWidget,
      );
      expect(
        find.text('Show at pharmacy or healthcare desk'),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('sets max brightness on mount and resets on unmount', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: BarcodeBottomSheet(
            contact: testContact,
            brightnessService: mockBrightnessService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockBrightnessService.setMaxBrightness()).called(1);
      verifyNever(() => mockBrightnessService.resetBrightness());

      // Replace widget to trigger unmount
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox.shrink()),
      );
      await tester.pumpAndSettle();

      verify(() => mockBrightnessService.resetBrightness()).called(1);
    });

    testWidgets('copies tax code to clipboard when copy button is tapped', (
      tester,
    ) async {
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          child: BarcodeBottomSheet(
            contact: testContact,
            brightnessService: mockBrightnessService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('barcode_bottom_sheet_copy_button')));
      await tester.pump();

      expect(
        log.any(
          (c) =>
              c.method == 'Clipboard.setData' &&
              (c.arguments as Map<Object?, Object?>?)?['text'] ==
                  'RSSMRA85D15H501Z',
        ),
        isTrue,
      );

      expect(find.text('Codice Fiscale copiato negli appunti'), findsOneWidget);
    });

    testWidgets('closes modal sheet when close button is tapped', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(
                    BarcodeBottomSheet.show(
                      context,
                      contact: testContact,
                      brightnessService: mockBrightnessService,
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BarcodeBottomSheet), findsOneWidget);

      final closeButtonFinder = find.byKey(const Key('barcode_bottom_sheet_close_button'));
      await tester.ensureVisible(closeButtonFinder);
      await tester.tap(closeButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(BarcodeBottomSheet), findsNothing);
    });

    testWidgets('closes modal sheet when header close icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(
                    BarcodeBottomSheet.show(
                      context,
                      contact: testContact,
                      brightnessService: mockBrightnessService,
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BarcodeBottomSheet), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('barcode_bottom_sheet_header_close_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BarcodeBottomSheet), findsNothing);
    });
  });
}
