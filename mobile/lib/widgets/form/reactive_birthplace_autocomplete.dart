import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_input.dart';

/// ReactiveForms adapter wrapper around [BirthplaceAutocompleteInput].
///
/// Binds the pure presentation autocomplete input to an [AbstractControl] / [FormControl],
/// synchronizing selection, clearing, touched state, and localized validation errors.
class ReactiveBirthplaceAutocomplete extends StatelessWidget {
  /// Reactive form control name when placed within a [ReactiveForm].
  final String? formControlName;

  /// Direct reactive control instance.
  final AbstractControl<dynamic>? formControl;

  /// External focus node to synchronize with scrolling or keyboard navigation.
  final FocusNode? focusNode;

  /// Full collection of birthplaces used for search filtering.
  final List<Birthplace> birthplaces;

  /// Custom label text overriding the default localized string.
  final String? labelText;

  /// Custom hint/placeholder text overriding the default localized string.
  final String? placeholder;

  /// Custom helper text displayed below the field overriding the default localized string.
  final String? helperText;

  /// Whether the field is mandatory (displays required asterisk when true).
  final bool isRequired;

  /// Optional custom validation error message mapping.
  final Map<String, ValidationMessageFunction>? validationMessages;

  const ReactiveBirthplaceAutocomplete({
    super.key,
    this.formControlName,
    this.formControl,
    this.focusNode,
    this.birthplaces = const [],
    this.labelText,
    this.placeholder,
    this.helperText,
    this.isRequired = true,
    this.validationMessages,
  }) : assert(
          formControlName != null || formControl != null,
          'Must provide either formControlName or formControl.',
        );

  @override
  Widget build(BuildContext context) {
    final control = formControl ??
        (ReactiveForm.of(context) as FormGroup?)?.control(formControlName!);

    return ReactiveValueListenableBuilder<dynamic>(
      formControl: control,
      builder: (context, currentControl, _) {
        final l10n = context.l10n;
        final hasError = currentControl.invalid && currentControl.touched;

        String? fieldError;
        if (hasError) {
          final errorKey = currentControl.errors.keys.firstOrNull;
          if (errorKey != null && validationMessages?.containsKey(errorKey) == true) {
            final error = currentControl.errors[errorKey];
            fieldError = validationMessages![errorKey]!(error as Object);
          } else {
            fieldError = l10n.required;
          }
        }

        return BirthplaceAutocompleteInput(
          focusNode: focusNode,
          birthplaces: birthplaces,
          value: currentControl.value as Birthplace?,
          onChanged: (selected) {
            currentControl.value = selected;
            currentControl.markAsTouched();
          },
          labelText: labelText,
          placeholder: placeholder,
          helperText: helperText,
          isRequired: isRequired,
          errorText: fieldError,
        );
      },
    );
  }
}
