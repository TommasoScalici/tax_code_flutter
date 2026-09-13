import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_field.dart';

void main() {
  group('BirthplaceAutocompleteField', () {
    const mockBirthplaces = [
      Birthplace(name: 'Roma', state: 'RM'),
      Birthplace(name: 'Milano', state: 'MI'),
      Birthplace(name: 'Napoli', state: 'NA'),
      Birthplace(name: 'Francia', state: 'EE'),
    ];

    Widget createStandaloneWidget({
      Locale locale = const Locale('it'),
      Birthplace? value,
      ValueChanged<Birthplace?>? onChanged,
      String? errorText,
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
            child: SingleChildScrollView(
              child: BirthplaceAutocompleteField(
                birthplaces: mockBirthplaces,
                value: value,
                onChanged: onChanged,
                errorText: errorText,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders Italian label, placeholder and helper text by default', (
      tester,
    ) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('Luogo di Nascita'), findsOneWidget);
      expect(find.text('Comune o Stato estero'), findsOneWidget);
      expect(
        find.text(
          'Digita il nome del comune per la ricerca rapida del codice catastale (es. H501).',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('renders English label, placeholder and helper text', (
      tester,
    ) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Place of Birth'), findsOneWidget);
      expect(find.text('Municipality or foreign country'), findsOneWidget);
      expect(
        find.text(
          'Type the municipality name for quick cadastral code lookup (e.g. H501).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('typing search query shows suggestions and allows selection', (
      tester,
    ) async {
      Birthplace? selected;
      await tester.pumpWidget(
        createStandaloneWidget(
          onChanged: (val) => selected = val,
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byKey(
        const Key('birthplace_autocomplete_textfield'),
      );
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, 'Rom');
      await tester.pumpAndSettle();

      expect(find.text('Roma'), findsOneWidget);
      expect(find.text('RM'), findsOneWidget);

      await tester.tap(find.text('Roma'));
      await tester.pumpAndSettle();

      expect(selected, const Birthplace(name: 'Roma', state: 'RM'));
    });

    testWidgets('clear button clears text input', (tester) async {
      Birthplace? selected = const Birthplace(name: 'Roma', state: 'RM');
      await tester.pumpWidget(
        createStandaloneWidget(
          value: selected,
          onChanged: (val) => selected = val,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('birthplace_clear_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('birthplace_clear_button')));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });

    testWidgets('integrates with ReactiveForm via formControlName', (
      tester,
    ) async {
      final form = FormGroup({
        'birthPlace': FormControl<Birthplace>(
          validators: [Validators.required],
        ),
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReactiveForm(
              formGroup: form,
              child: const BirthplaceAutocompleteField(
                formControlName: 'birthPlace',
                birthplaces: mockBirthplaces,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(form.control('birthPlace').value, isNull);
      expect(find.byKey(const Key('birthplace_autocomplete_textfield')), findsOneWidget);
    });
  });
}
