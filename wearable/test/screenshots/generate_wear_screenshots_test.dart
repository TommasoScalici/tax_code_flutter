import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

//--- Mocks ---//

class MockAuthService extends Mock implements AuthService {}

class MockContactsListController extends Mock
    implements ContactsListController {}

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

//--- Scenario Definition ---//

class _WearScenario {
  const _WearScenario({
    required this.filename,
    required this.widgetBuilder,
  });

  final String filename;
  final Widget Function(Locale locale) widgetBuilder;
}

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  String? findFlutterRoot() {
    final flutterRootEnv = Platform.environment['FLUTTER_ROOT'];
    if (flutterRootEnv != null && flutterRootEnv.isNotEmpty) {
      return flutterRootEnv;
    }
    final pathEnv = Platform.environment['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';
    for (final dir in pathEnv.split(separator)) {
      if (dir.isEmpty) continue;
      final cleanDir = dir.replaceAll('"', '');
      final flutterExe = File(
        Platform.isWindows ? '$cleanDir\\flutter.bat' : '$cleanDir/flutter',
      );
      if (flutterExe.existsSync()) {
        return Directory(cleanDir).parent.path;
      }
    }
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null) {
      final candidate = '$localAppData\\flutter';
      if (Directory(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  Future<void> loadFonts(WidgetTester tester) async {
    await tester.runAsync(() async {
      final winDir = Platform.environment['WINDIR'] ??
          Platform.environment['SYSTEMROOT'] ??
          r'C:\Windows';

      // 1. Text fonts (Segoe UI, Arial, Roboto, Inter with regular and bold)
      final fontFiles = [
        '$winDir\\Fonts\\segoeui.ttf',
        '$winDir\\Fonts\\segoeuib.ttf',
        '$winDir\\Fonts\\segoeuisl.ttf',
        '$winDir\\Fonts\\arial.ttf',
        '$winDir\\Fonts\\arialbd.ttf',
      ];

      for (final family in [
        'Segoe UI',
        'Arial',
        'Roboto',
        'Inter',
      ]) {
        final loader = FontLoader(family);
        for (final path in fontFiles) {
          final file = File(path);
          if (file.existsSync()) {
            final fontData = await file.readAsBytes();
            loader.addFont(Future.value(ByteData.sublistView(fontData)));
          }
        }
        await loader.load();
      }

      // 2. Monospace fonts (for Codice Fiscale badge and optical presentation)
      final monoFiles = [
        '$winDir\\Fonts\\consola.ttf',
        '$winDir\\Fonts\\consolab.ttf',
        '$winDir\\Fonts\\cour.ttf',
        '$winDir\\Fonts\\courbd.ttf',
      ];

      for (final family in [
        'monospace',
        'Courier',
        'Consolas',
      ]) {
        final loader = FontLoader(family);
        for (final path in monoFiles) {
          final file = File(path);
          if (file.existsSync()) {
            final fontData = await file.readAsBytes();
            loader.addFont(Future.value(ByteData.sublistView(fontData)));
          }
        }
        await loader.load();
      }

      // 3. MaterialIcons font
      final flutterRoot = findFlutterRoot();
      if (flutterRoot != null) {
        final miFile = File(
          Platform.isWindows
              ? '$flutterRoot\\bin\\cache\\artifacts\\material_fonts\\materialicons-regular.otf'
              : '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
        );
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
      }
    });
  }

  final sampleMarioRossi = Contact(
    id: 'sample-1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: 'RSSMRA80A01H501U',
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    birthDate: DateTime(1980),
    listIndex: 0,
  );

  final sampleLauraBianchi = Contact(
    id: 'sample-2',
    firstName: 'Laura',
    lastName: 'Bianchi',
    gender: 'F',
    taxCode: 'BNCLRA85M41F205Z',
    birthPlace: const Birthplace(name: 'Milano', state: 'MI'),
    birthDate: DateTime(1985, 8),
    listIndex: 1,
  );

  // Mocks setup
  late MockAuthService mockAuthService;
  late MockContactsListController mockEmptyController;
  late MockContactsListController mockLoadedController;
  late MockNativeViewService mockNativeViewService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);

    mockEmptyController = MockContactsListController();
    when(() => mockEmptyController.addListener(any())).thenAnswer((_) {});
    when(() => mockEmptyController.removeListener(any())).thenAnswer((_) {});
    when(() => mockEmptyController.contacts).thenReturn([]);
    when(() => mockEmptyController.hasContacts).thenReturn(false);
    when(() => mockEmptyController.isLoading).thenReturn(false);
    when(() => mockEmptyController.isDemoMode).thenReturn(false);
    when(() => mockEmptyController.isLaunchingPhoneApp).thenReturn(false);

    mockLoadedController = MockContactsListController();
    when(() => mockLoadedController.addListener(any())).thenAnswer((_) {});
    when(() => mockLoadedController.removeListener(any())).thenAnswer((_) {});
    when(
      () => mockLoadedController.contacts,
    ).thenReturn([sampleMarioRossi, sampleLauraBianchi]);
    when(() => mockLoadedController.hasContacts).thenReturn(true);
    when(() => mockLoadedController.isLoading).thenReturn(false);
    when(() => mockLoadedController.isDemoMode).thenReturn(false);
    when(() => mockLoadedController.isLaunchingPhoneApp).thenReturn(false);

    mockNativeViewService = MockNativeViewService();
    when(
      () => mockNativeViewService.enableHighBrightnessMode(),
    ).thenAnswer((_) async {});
    when(
      () => mockNativeViewService.disableHighBrightnessMode(),
    ).thenAnswer((_) async {});
  });

  final scenarios = [
    // 1) Welcome / Login screen
    _WearScenario(
      filename: '01_welcome_login',
      widgetBuilder: (locale) => ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: const AuthGate(homePage: SizedBox()),
      ),
    ),

    // 2) Empty state (companion sync invite)
    _WearScenario(
      filename: '02_empty_state',
      widgetBuilder: (locale) =>
          ChangeNotifierProvider<ContactsListController>.value(
        value: mockEmptyController,
        child: const ContactsList(),
      ),
    ),

    // 3) Contacts list
    _WearScenario(
      filename: '03_contacts_list',
      widgetBuilder: (locale) =>
          ChangeNotifierProvider<ContactsListController>.value(
        value: mockLoadedController,
        child: const ContactsList(),
      ),
    ),

    // 4) Barcode Code 128 (1D)
    _WearScenario(
      filename: '04_barcode_code128',
      widgetBuilder: (locale) => Provider<NativeViewServiceAbstract>.value(
        value: mockNativeViewService,
        child: BarcodePage(
          taxCode: sampleMarioRossi.taxCode,
          contact: sampleMarioRossi,
        ),
      ),
    ),

    // 5) Barcode QR Code (2D)
    _WearScenario(
      filename: '05_barcode_qr',
      widgetBuilder: (locale) => Provider<NativeViewServiceAbstract>.value(
        value: mockNativeViewService,
        child: BarcodePage(
          taxCode: sampleMarioRossi.taxCode,
          contact: sampleMarioRossi,
          initialIsQrCode: true,
        ),
      ),
    ),
  ];

  final locales = {
    'it': const Locale('it'),
    'en': const Locale('en'),
  };

  testWidgets(
    'Generate all Google Play Store showcase screenshots for Wear OS',
    (tester) async {
      await loadFonts(tester);

      var totalGenerated = 0;
      const canvasDimension = 512.0;
      const logicalDimension = 200.0;

      for (final localeEntry in locales.entries) {
        final langKey = localeEntry.key;
        final locale = localeEntry.value;

        final outputDir = Directory('screenshots/play_store/$langKey');
        if (!outputDir.existsSync()) {
          outputDir.createSync(recursive: true);
        }

        // Set device surface size for exact 1:1 rendering at 512x512
        tester.view.physicalSize =
            const Size(canvasDimension, canvasDimension);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(
          const Size(canvasDimension, canvasDimension),
        );

        for (final scenario in scenarios) {
          final repaintKey = GlobalKey();

          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Settings.getWearTheme().copyWith(
                textTheme: Settings.getWearTheme().textTheme.apply(
                      fontFamily: 'Segoe UI',
                    ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: Settings.getWearTheme().elevatedButtonTheme.style?.copyWith(
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontFamily: 'Segoe UI'),
                    ),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: Settings.getWearTheme().outlinedButtonTheme.style?.copyWith(
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontFamily: 'Segoe UI'),
                    ),
                  ),
                ),
              ),
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                backgroundColor: Colors.black,
                body: RepaintBoundary(
                  key: repaintKey,
                  child: Container(
                    width: canvasDimension,
                    height: canvasDimension,
                    color: Colors.black,
                    child: Center(
                      child: ClipOval(
                        child: SizedBox(
                          width: canvasDimension,
                          height: canvasDimension,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: logicalDimension,
                              height: logicalDimension,
                              child: MediaQuery(
                                data: const MediaQueryData(
                                  size: Size(
                                    logicalDimension,
                                    logicalDimension,
                                  ),
                                  devicePixelRatio: 2.56,
                                ),
                                child: scenario.widgetBuilder(locale),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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

            final targetFile =
                File('${outputDir.path}/${scenario.filename}.png');
            await targetFile.writeAsBytes(bytes);

            expect(targetFile.existsSync(), isTrue);
            expect(bytes.length, greaterThan(1000));
            totalGenerated++;
          });
        }
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      addTearDown(() async {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        await tester.binding.setSurfaceSize(null);
      });

      // 2 languages x 5 scenarios = 10 screenshots
      expect(totalGenerated, 10);
    },
  );
}
