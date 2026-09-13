import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/form_section_divider.dart';

void main() {
  group('FormSectionDivider', () {
    Widget createTestWidget({
      Locale locale = const Locale('it'),
      String? customLabel,
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
            child: FormSectionDivider(
              label: customLabel,
            ),
          ),
        ),
      );
    }

    testWidgets('renders default Italian text in uppercase and two dividers', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('OPPURE INSERISCI MANUALMENTE'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders default English text in uppercase', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('OR ENTER MANUALLY'), findsOneWidget);
    });

    testWidgets('renders custom label correctly in uppercase', (tester) async {
      await tester.pumpWidget(
        createTestWidget(customLabel: 'Altre Opzioni'),
      );
      await tester.pumpAndSettle();

      expect(find.text('ALTRE OPZIONI'), findsOneWidget);
    });

    testWidgets('renders without error in light theme', (tester) async {
      await tester.pumpWidget(
        createTestWidget(themeMode: ThemeMode.light),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FormSectionDivider), findsOneWidget);
      expect(find.text('OPPURE INSERISCI MANUALMENTE'), findsOneWidget);
    });
  });
}
