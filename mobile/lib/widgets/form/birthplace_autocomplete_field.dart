import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_input.dart';
import 'package:tax_code_flutter/widgets/form/reactive_birthplace_autocomplete.dart';

export 'birthplace_autocomplete_input.dart';
export 'birthplace_options_overlay.dart';
export 'reactive_birthplace_autocomplete.dart';

/// A modern autocomplete field for Italian municipalities and foreign countries,
/// featuring location pin icon, clear button, cadastral code badge, and helper text.
///
/// Automatically switches between reactive mode (when [formControlName] or [formControl] is set)
/// and standalone mode (when operating independently with [value] and [onChanged]).
class BirthplaceAutocompleteField extends StatelessWidget {
  /// Reactive form control name when used inside [ReactiveForm].
  final String? formControlName;

  /// Direct reactive control instance.
  final AbstractControl<dynamic>? formControl;

  /// External focus node to synchronize with page scrolling or navigation.
  final FocusNode? focusNode;

  /// Optional custom label text.
  final String? labelText;

  /// Full collection of birthplaces for filtering.
  final List<Birthplace> birthplaces;

  /// Callback when a birthplace is selected or cleared in standalone mode.
  final ValueChanged<Birthplace?>? onChanged;

  /// Current value when used in standalone mode without ReactiveForms.
  final Birthplace? value;

  /// Whether the field is required (displays asterisk when true).
  final bool isRequired;

  /// Custom error message to display in standalone mode.
  final String? errorText;

  const BirthplaceAutocompleteField({
    super.key,
    this.formControlName,
    this.formControl,
    this.focusNode,
    this.labelText,
    this.birthplaces = const [],
    this.onChanged,
    this.value,
    this.isRequired = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (formControlName != null || formControl != null) {
      return ReactiveBirthplaceAutocomplete(
        formControlName: formControlName,
        formControl: formControl,
        focusNode: focusNode,
        birthplaces: birthplaces,
        labelText: labelText,
        isRequired: isRequired,
      );
    }

    return BirthplaceAutocompleteInput(
      focusNode: focusNode,
      birthplaces: birthplaces,
      value: value,
      onChanged: onChanged,
      labelText: labelText,
      isRequired: isRequired,
      errorText: errorText,
    );
  }
}
