import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/form/birthdate_picker_field.dart';

void main() {
  group('BirthdatePickerField', () {
    Widget createStandaloneWidget({
      Locale locale = const Locale('it'),
      DateTime? value,
      ValueChanged<DateTime?>? onChanged,
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
            child: BirthdatePickerField(
              value: value,
              onChanged: onChanged,
              errorText: errorText,
            ),
          ),
        ),
      );
    }

    testWidgets('renders Italian label and placeholder by default', (
      tester,
    ) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('Data di Nascita'), findsOneWidget);
      expect(find.text('GG/MM/AAAA'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('renders English label and placeholder properly', (
      tester,
    ) async {
      await tester.pumpWidget(createStandaloneWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('DD/MM/YYYY'), findsOneWidget);
    });

    testWidgets('displays formatted date and clear button when date is set', (
      tester,
    ) async {
      final testDate = DateTime(1990, 5, 20);
      DateTime? updatedDate = testDate;

      await tester.pumpWidget(
        createStandaloneWidget(
          value: testDate,
          onChanged: (val) => updatedDate = val,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('birthdate_picker_clear_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('birthdate_picker_clear_button')));
      await tester.pumpAndSettle();

      expect(updatedDate, isNull);
    });

    testWidgets('tapping picker opens date picker dialog', (tester) async {
      await tester.pumpWidget(createStandaloneWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('birthdate_picker_inkwell')));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('integrates with ReactiveForm via formControlName', (
      tester,
    ) async {
      final form = FormGroup({
        'birthDate': FormControl<DateTime>(
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
              child: BirthdatePickerField(
                formControlName: 'birthDate',
                validationMessages: {
                  ValidationMessage.required: (error) => 'Obbligatorio',
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(form.control('birthDate').value, isNull);
      expect(find.text('GG/MM/AAAA'), findsOneWidget);
    });
  });
}
