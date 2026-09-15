import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_screen_preview.dart';
import 'package:tax_code_flutter/widgets/previews/form_screen_preview.dart';

import 'showcase_canvas.dart';

class _Scenario {
  const _Scenario({
    required this.filename,
    required this.itHeadline,
    required this.itSubtitle,
    required this.enHeadline,
    required this.enSubtitle,
    required this.widgetBuilder,
  });

  final String filename;
  final String itHeadline;
  final String itSubtitle;
  final String enHeadline;
  final String enSubtitle;
  final Widget Function(Locale locale) widgetBuilder;
}

Widget _buildBarcodeScenario(Locale locale, Contact contact) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.light,
    locale: locale,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background dashboard preview
          Opacity(
            opacity: 0.35,
            child: DashboardScreenPreview(
              locale: locale,
              initialContacts: [contact],
            ),
          ),
          // Scrim overlay
          const ModalBarrier(
            dismissible: false,
            color: Colors.black45,
          ),
          // Elevated Barcode Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 32,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(28)),
                child: BarcodeBottomSheet(
                  contact: contact,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> loadFonts(WidgetTester tester) async {
    await tester.runAsync(() async {
      // 1. Text fonts (Inter, Arial, JetBrains Mono, Roboto)
      final fontFiles = [
        r'C:\Windows\Fonts\segoeui.ttf',
        r'C:\Windows\Fonts\arial.ttf',
      ];

      for (final path in fontFiles) {
        final file = File(path);
        if (file.existsSync()) {
          final fontData = await file.readAsBytes();
          for (final family in [
            'Arial',
            'Inter',
            'JetBrainsMono',
            'JetBrains Mono',
            'Roboto',
          ]) {
            final loader = FontLoader(family)
              ..addFont(Future.value(ByteData.sublistView(fontData)));
            await loader.load();
          }
          break;
        }
      }

      // 2. MaterialIcons font
      const materialIconsPath =
          r'C:\Users\Tommaso\AppData\Local\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf';
      final miFile = File(materialIconsPath);
      if (miFile.existsSync()) {
        final data = await miFile.readAsBytes();
        for (final family in [
          'MaterialIcons',
          'packages/flutter/MaterialIcons',
        ]) {
          final loader = FontLoader(family)
            ..addFont(Future.value(ByteData.sublistView(data)));
          await loader.load();
        }
      }

      // 3. MaterialSymbols icons
      final pubCache = Platform.environment['LOCALAPPDATA'];
      if (pubCache != null) {
        final symbolsFiles = [
          'MaterialSymbolsRounded',
          'MaterialSymbolsOutlined',
          'MaterialSymbolsSharp',
        ];
        for (final sym in symbolsFiles) {
          final symPath =
              '$pubCache\\Pub\\Cache\\hosted\\pub.dev\\material_symbols_icons-4.2960.0\\lib\\fonts\\$sym.ttf';
          final symFile = File(symPath);
          if (symFile.existsSync()) {
            final data = await symFile.readAsBytes();
            for (final family in [
              sym,
              'packages/material_symbols_icons/$sym',
            ]) {
              final loader = FontLoader(family)
                ..addFont(Future.value(ByteData.sublistView(data)));
              await loader.load();
            }
          }
        }
      }
    });
  }

  final sampleContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1980, 1, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  final scenarios = [
    _Scenario(
      filename: '01_dashboard_empty',
      itHeadline: 'Tutti i tuoi codici fiscali, sempre con te',
      itSubtitle:
          'Archivia, organizza e consulta in qualsiasi momento, anche offline.',
      enHeadline: 'Your tax codes, always with you',
      enSubtitle: 'Store, organize and access anytime, fully offline.',
      widgetBuilder: (locale) => DashboardScreenPreview(
        locale: locale,
        initialContacts: const [],
      ),
    ),
    _Scenario(
      filename: '02_dashboard_contacts',
      itHeadline: 'Gestione multipla e verifica istantanea',
      itSubtitle:
          'Elenco intuitivo, ricerca istantanea e badge con codice verificato.',
      enHeadline: 'Multi-profile storage & verified codes',
      enSubtitle:
          'Intuitive list, instant search and verified fiscal code badge.',
      widgetBuilder: (locale) => DashboardScreenPreview(locale: locale),
    ),
    _Scenario(
      filename: '03_form_completed',
      itHeadline: 'Calcolo in tempo reale con anteprima live',
      itSubtitle:
          "Inserisci i dati anagrafici e visualizza il codice all'istante.",
      enHeadline: 'Real-time calculation with live preview',
      enSubtitle: 'Fill in personal details and see the tax code update live.',
      widgetBuilder: (locale) => FormScreenPreview(
        locale: locale,
        initialContact: sampleContact,
      ),
    ),
    _Scenario(
      filename: '04_barcode_qr',
      itHeadline: 'Tessera sanitaria digitale sempre a portata',
      itSubtitle:
          'Codice a barre Code 39 e QR Code pronti per farmacie e studi medici.',
      enHeadline: 'Digital health card with barcode & QR',
      enSubtitle:
          'Standard Code 39 barcode and QR code ready for pharmacies & clinics.',
      widgetBuilder: (locale) => _buildBarcodeScenario(locale, sampleContact),
    ),
    _Scenario(
      filename: '05_ocr_ai',
      itHeadline: 'Scansione intelligente con Gemini IA',
      itSubtitle:
          'Inquadra la tessera: estrazione automatica dei dati in un istante.',
      enHeadline: 'Smart document scanning with Gemini AI',
      enSubtitle: 'Point at the health card: instant automatic data extraction.',
      widgetBuilder: (locale) => FormScreenPreview(
        locale: locale,
      ),
    ),
  ];

  final devices = {
    'phone': ShowcaseDeviceSpec.phone,
    'tablet_7': ShowcaseDeviceSpec.tablet7,
    'tablet_10': ShowcaseDeviceSpec.tablet10,
  };

  final locales = {
    'it': const Locale('it'),
    'en': const Locale('en'),
  };

  testWidgets('Generate all Google Play Store showcase screenshots', (
    tester,
  ) async {
    await loadFonts(tester);

    var totalGenerated = 0;

    for (final localeEntry in locales.entries) {
      final langKey = localeEntry.key;
      final locale = localeEntry.value;

      for (final deviceEntry in devices.entries) {
        final deviceKey = deviceEntry.key;
        final spec = deviceEntry.value;

        final outputDir = Directory(
          'screenshots/play_store/$langKey/$deviceKey',
        );
        if (!outputDir.existsSync()) {
          outputDir.createSync(recursive: true);
        }

        // Set device surface size for exact pixel-perfect rendering
        tester.view.physicalSize = Size(spec.canvasWidth, spec.canvasHeight);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(
          Size(spec.canvasWidth, spec.canvasHeight),
        );

        for (final scenario in scenarios) {
          final headline =
              langKey == 'it' ? scenario.itHeadline : scenario.enHeadline;
          final subtitle =
              langKey == 'it' ? scenario.itSubtitle : scenario.enSubtitle;

          final repaintKey = GlobalKey();

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: RepaintBoundary(
                key: repaintKey,
                child: StoreShowcaseCanvas(
                  spec: spec,
                  headline: headline,
                  subtitle: subtitle,
                  child: scenario.widgetBuilder(locale),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.runAsync(() async {
            final boundary =
                repaintKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final byteData = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final bytes = byteData!.buffer.asUint8List();

            final targetFile = File('${outputDir.path}/${scenario.filename}.png');
            await targetFile.writeAsBytes(bytes);

            expect(targetFile.existsSync(), isTrue);
            expect(bytes.length, greaterThan(1000));
            totalGenerated++;
          });
        }
      }
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });

    // 2 languages x 3 devices x 5 scenarios = 30 screenshots
    expect(totalGenerated, 30);
  });
}
