import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/ocr_ai_hero_banner.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('OcrAiHeroBanner', () {
    late MockVoidCallback mockOnScanPressed;

    setUp(() {
      mockOnScanPressed = MockVoidCallback();
    });

    Widget createTestWidget({
      Locale locale = const Locale('it'),
      ThemeMode themeMode = ThemeMode.dark,
    }) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: Center(
            child: OcrAiHeroBanner(
              onScanPressed: mockOnScanPressed.call,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all Italian texts, icons and AI badge correctly', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('Scansione Smart con Fotocamera'), findsOneWidget);
      expect(
        find.text(
          'Inquadra Tessera Sanitaria o CIE per compilare tutti i campi in automatico tramite AI.',
        ),
        findsOneWidget,
      );
      expect(find.text('Scansiona'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);

      expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders all English texts correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Smart Camera Scan'), findsOneWidget);
      expect(
        find.text(
          'Frame Health Card or ID card to automatically fill all fields via AI.',
        ),
        findsOneWidget,
      );
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
    });

    testWidgets('tapping scan button triggers onScanPressed callback', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scanButtonFinder = find.byType(FilledButton);
      expect(scanButtonFinder, findsOneWidget);

      await tester.tap(scanButtonFinder);
      await tester.pumpAndSettle();

      verify(() => mockOnScanPressed.call()).called(1);
    });

    testWidgets('tapping anywhere on the banner triggers onScanPressed callback', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final inkWellFinder = find.byKey(
        const Key('ocr_ai_hero_banner_ink_well'),
      );
      expect(inkWellFinder, findsOneWidget);

      await tester.tap(inkWellFinder);
      await tester.pumpAndSettle();

      verify(() => mockOnScanPressed.call()).called(1);
    });

    testWidgets('renders properly in light theme without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(themeMode: ThemeMode.light),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OcrAiHeroBanner), findsOneWidget);
      expect(find.text('Scansione Smart con Fotocamera'), findsOneWidget);
    });
  });
}
