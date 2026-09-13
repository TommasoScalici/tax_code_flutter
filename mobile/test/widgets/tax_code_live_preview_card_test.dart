import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/form/tax_code_live_preview_card.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('TaxCodeLivePreviewCard', () {
    late MockVoidCallback mockOnCopied;

    setUp(() {
      mockOnCopied = MockVoidCallback();
    });

    Widget createTestWidget({
      Locale locale = const Locale('it'),
      String? taxCode,
      VoidCallback? onCopied,
      ThemeMode themeMode = ThemeMode.dark,
    }) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: Center(
            child: TaxCodeLivePreviewCard(
              taxCode: taxCode,
              onCopied: onCopied,
            ),
          ),
        ),
      );
    }

    testWidgets('renders Italian title and hint when tax code is empty', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('CODICE CALCOLATO IN ANTEPRIMA'), findsOneWidget);
      expect(
        find.text('Compila tutti i campi per il calcolo automatico'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.pending_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);
    });

    testWidgets('renders English title and hint when in English locale', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('LIVE CALCULATED TAX CODE'), findsOneWidget);
      expect(
        find.text('Fill in all fields for automatic calculation'),
        findsOneWidget,
      );
    });

    testWidgets('renders full code, verified icon, and copy button when complete', (
      tester,
    ) async {
      const fullCode = 'RSSMRA85D15H501Z';

      await tester.pumpWidget(
        createTestWidget(
          taxCode: fullCode,
          onCopied: mockOnCopied.call,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(fullCode), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      expect(
        find.byKey(const Key('tax_code_live_preview_copy_button')),
        findsOneWidget,
      );

      // Tap copy button
      await tester.tap(find.byKey(const Key('tax_code_live_preview_copy_button')));
      await tester.pumpAndSettle();

      verify(() => mockOnCopied.call()).called(1);
    });

    testWidgets('tapping entire card copies code when complete', (tester) async {
      const fullCode = 'RSSMRA85D15H501Z';

      await tester.pumpWidget(
        createTestWidget(
          taxCode: fullCode,
          onCopied: mockOnCopied.call,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tax_code_live_preview_inkwell')));
      await tester.pumpAndSettle();

      verify(() => mockOnCopied.call()).called(1);
    });
  });
}
