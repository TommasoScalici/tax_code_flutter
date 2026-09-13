import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/form/gender_segmented_button.dart';

void main() {
  group('GenderSegmentedButton', () {
    Widget createStandaloneWidget({
      Locale locale = const Locale('it'),
      String? value,
      ValueChanged<String?>? onChanged,
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
            child: GenderSegmentedButton(
              value: value,
              onChanged: onChanged,
              errorText: errorText,
            ),
          ),
        ),
      );
    }

    testWidgets('renders Italian labels and asterisk by default', (
      tester,
    ) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('Sesso'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('Maschile (M)'), findsOneWidget);
      expect(find.text('Femminile (F)'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('renders English labels properly', (tester) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Male (M)'), findsOneWidget);
      expect(find.text('Female (F)'), findsOneWidget);
    });

    testWidgets('displays checkmark when value is selected', (tester) async {
      await tester.pumpWidget(createStandaloneWidget(value: 'M'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('tapping male segment triggers onChanged with M', (
      tester,
    ) async {
      String? updatedValue;
      await tester.pumpWidget(
        createStandaloneWidget(
          value: null,
          onChanged: (val) => updatedValue = val,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_segment_m')));
      await tester.pumpAndSettle();

      expect(updatedValue, 'M');
    });

    testWidgets('tapping female segment triggers onChanged with F', (
      tester,
    ) async {
      String? updatedValue;
      await tester.pumpWidget(
        createStandaloneWidget(
          value: 'M',
          onChanged: (val) => updatedValue = val,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_segment_f')));
      await tester.pumpAndSettle();

      expect(updatedValue, 'F');
    });

    testWidgets('tapping active segment deselects it', (tester) async {
      String? updatedValue = 'M';
      await tester.pumpWidget(
        createStandaloneWidget(
          value: 'M',
          onChanged: (val) => updatedValue = val,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_segment_m')));
      await tester.pumpAndSettle();

      expect(updatedValue, isNull);
    });

    testWidgets('renders error text when errorText is passed', (tester) async {
      await tester.pumpWidget(
        createStandaloneWidget(errorText: 'Campo obbligatorio'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campo obbligatorio'), findsOneWidget);
    });

    testWidgets('integrates with ReactiveForm via formControlName', (
      tester,
    ) async {
      final form = FormGroup({
        'gender': FormControl<String>(
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
              child: GenderSegmentedButton(
                formControlName: 'gender',
                validationMessages: {
                  ValidationMessage.required: (error) => 'Obbligatorio',
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(form.control('gender').value, isNull);

      // Tap male segment
      await tester.tap(find.byKey(const Key('gender_segment_m')));
      await tester.pumpAndSettle();

      expect(form.control('gender').value, 'M');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
