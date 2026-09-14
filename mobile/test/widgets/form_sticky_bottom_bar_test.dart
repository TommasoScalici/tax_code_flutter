import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/form_sticky_bottom_bar.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('FormStickyBottomBar', () {
    late MockVoidCallback mockOnSavePressed;

    setUp(() {
      mockOnSavePressed = MockVoidCallback();
    });

    Widget createTestWidget({
      Locale locale = const Locale('it'),
      bool isEnabled = true,
      bool isLoading = false,
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
          body: FormStickyBottomBar(
            onSavePressed: mockOnSavePressed.call,
            isEnabled: isEnabled,
            isLoading: isLoading,
            labelText: customLabel,
          ),
        ),
      );
    }

    testWidgets('renders default Italian label and calculate icon', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Salva Codice'), findsOneWidget);
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    });

    testWidgets('renders English label properly', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Save Code'), findsOneWidget);
    });

    testWidgets('calls onSavePressed when tapped and enabled', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('form_sticky_bottom_bar_button')));
      await tester.pumpAndSettle();

      verify(() => mockOnSavePressed.call()).called(1);
    });

    testWidgets('does not call onSavePressed when disabled', (tester) async {
      await tester.pumpWidget(createTestWidget(isEnabled: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('form_sticky_bottom_bar_button')));
      await tester.pumpAndSettle();

      verifyNever(() => mockOnSavePressed.call());
    });

    testWidgets('displays CircularProgressIndicator when loading', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.calculate_rounded), findsNothing);
    });
  });
}
