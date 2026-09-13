import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/utils/tax_code_generator.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/validators/only_letters_validator.dart';
import 'package:tax_code_flutter/widgets/form/birthdate_picker_field.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_field.dart';
import 'package:tax_code_flutter/widgets/form/custom_text_field.dart';
import 'package:tax_code_flutter/widgets/form/form_section_divider.dart';
import 'package:tax_code_flutter/widgets/form/form_sticky_bottom_bar.dart';
import 'package:tax_code_flutter/widgets/form/gender_segmented_button.dart';
import 'package:tax_code_flutter/widgets/form/ocr_ai_hero_banner.dart';
import 'package:tax_code_flutter/widgets/form/tax_code_live_preview_card.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

/// Full screen interactive preview for the modernized Form Screen (Task 6.9).
///
/// Showcases [OcrAiHeroBanner], [FormSectionDivider], [CustomTextField],
/// [GenderSegmentedButton], [BirthdatePickerField], [BirthplaceAutocompleteField],
/// [TaxCodeLivePreviewCard], and [FormStickyBottomBar] in action.
///
/// Features interactive toggles for:
/// - Light vs Dark mode
/// - New Tax Code creation vs Edit mode
/// - Interactive AI scan simulation to auto-populate form
class FormScreenPreview extends StatefulWidget {
  @Preview(name: 'Form Screen')
  const FormScreenPreview({super.key});

  @override
  State<FormScreenPreview> createState() => _FormScreenPreviewState();
}

class _FormScreenPreviewState extends State<FormScreenPreview> {
  bool _isDarkMode = true;
  bool _isEditing = false;
  bool _isSubmitting = false;

  final List<Birthplace> _birthplaces = const [
    Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
    Birthplace(name: 'Napoli', state: 'NA', code: 'F839'),
    Birthplace(name: 'Torino', state: 'TO', code: 'L219'),
    Birthplace(name: 'Palermo', state: 'PA', code: 'G273'),
    Birthplace(name: 'Firenze', state: 'FI', code: 'D612'),
    Birthplace(name: 'Bologna', state: 'BO', code: 'A944'),
  ];

  late FormGroup _form;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  void _initForm({Contact? contact}) {
    _form = fb.group({
      'firstName': FormControl<String>(
        value: contact?.firstName,
        validators: [Validators.required, const OnlyLettersValidator()],
      ),
      'lastName': FormControl<String>(
        value: contact?.lastName,
        validators: [Validators.required, const OnlyLettersValidator()],
      ),
      'gender': FormControl<String>(
        value: contact?.gender,
        validators: [Validators.required],
      ),
      'birthDate': FormControl<DateTime>(
        value: contact?.birthDate,
        validators: [Validators.required],
      ),
      'birthPlace': FormControl<Birthplace>(
        value: contact?.birthPlace,
        validators: [Validators.required],
      ),
    });
  }

  void _simulateScanData() {
    _form.patchValue({
      'firstName': 'Laura',
      'lastName': 'Neri',
      'gender': 'F',
      'birthDate': DateTime(1985, 10, 20),
      'birthPlace': _birthplaces.firstWhere((b) => b.code == 'F205'),
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dati scansionati con AI e inseriti con successo!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _initForm(
          contact: Contact(
            id: 'demo-1',
            firstName: 'Mario',
            lastName: 'Rossi',
            gender: 'M',
            birthDate: DateTime(1980, 1, 15),
            birthPlace: _birthplaces.first,
            taxCode: 'RSSMRA80A15H501U',
            listIndex: 0,
          ),
        );
      } else {
        _initForm();
      }
    });
  }

  String? _calculateTaxCode() {
    try {
      final firstName = _form.control('firstName').value as String?;
      final lastName = _form.control('lastName').value as String?;
      final gender = _form.control('gender').value as String?;
      final birthDate = _form.control('birthDate').value as DateTime?;
      final birthPlace = _form.control('birthPlace').value as Birthplace?;

      if (firstName == null ||
          firstName.trim().isEmpty ||
          lastName == null ||
          lastName.trim().isEmpty ||
          gender == null ||
          (gender != 'M' && gender != 'F') ||
          birthDate == null ||
          birthPlace == null ||
          birthPlace.code.isEmpty) {
        return null;
      }

      return TaxCodeGenerator.generate(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        dateOfBirth: birthDate,
        gender: gender,
        birthplaceCode: birthPlace.code,
      );
    } on Object {
      return null;
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      final code = _calculateTaxCode() ?? 'RSSMRA80A15H501U';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Codice fiscale salvato con successo: $code'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Torna alla dashboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              title: Text(
                _isEditing ? l10n.editTaxCodeTitle : l10n.newTaxCodeTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
              actions: [
                // Toggle mode (New vs Edit)
                IconButton(
                  tooltip: _isEditing ? 'Modalità Crea' : 'Modalità Modifica',
                  icon: Icon(
                    _isEditing
                        ? Icons.add_circle_outline_rounded
                        : Icons.edit_note_rounded,
                  ),
                  onPressed: _toggleEditMode,
                ),
                // Toggle Theme
                IconButton(
                  tooltip: _isDarkMode ? 'Tema Chiaro' : 'Tema Scuro',
                  icon: Icon(
                    _isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                  },
                ),
              ],
            ),
            bottomNavigationBar: ReactiveFormBuilder(
              form: () => _form,
              builder: (context, form, child) {
                return FormStickyBottomBar(
                  labelText: l10n.saveCode,
                  isEnabled: form.valid && !_isSubmitting,
                  isLoading: _isSubmitting,
                  onPressed: (form.valid && !_isSubmitting)
                      ? _handleSubmit
                      : null,
                );
              },
            ),
            body: ResponsiveLayout(
              maxWidth: 520.0,
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ReactiveForm(
                  formGroup: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // OCR Banner (creation only)
                      if (!_isEditing) ...[
                        OcrAiHeroBanner(
                          onScanPressed: _simulateScanData,
                        ),
                        const SizedBox(height: 18),
                        const FormSectionDivider(),
                        const SizedBox(height: 18),
                      ],

                      // First Name
                      CustomTextField(
                        formControlName: 'firstName',
                        labelText: l10n.firstName,
                        placeholder: l10n.firstNamePlaceholder,
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.required,
                          'invalidCharacters': (_) => l10n.invalidCharacters,
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      CustomTextField(
                        formControlName: 'lastName',
                        labelText: l10n.lastName,
                        placeholder: l10n.lastNamePlaceholder,
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.required,
                          'invalidCharacters': (_) => l10n.invalidCharacters,
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      GenderSegmentedButton(
                        formControlName: 'gender',
                        labelText: l10n.gender,
                      ),
                      const SizedBox(height: 16),

                      // Birth Date
                      BirthdatePickerField(
                        formControlName: 'birthDate',
                        labelText: l10n.birthDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 16),

                      // Birth Place
                      BirthplaceAutocompleteField(
                        formControlName: 'birthPlace',
                        labelText: l10n.birthPlace,
                        birthplaces: _birthplaces,
                      ),
                      const SizedBox(height: 20),

                      // Live preview card
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return TaxCodeLivePreviewCard(
                            taxCode: _calculateTaxCode(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
