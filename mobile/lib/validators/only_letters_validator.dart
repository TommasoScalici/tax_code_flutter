import 'package:reactive_forms/reactive_forms.dart';

/// Validator that checks if a control's value contains only letters,
/// spaces, and apostrophes.
class OnlyLettersValidator extends Validator<String> {
  const OnlyLettersValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<String> control) {
    if (control.value == null || control.value!.isEmpty) {
      return null;
    }

    final hasInvalidCharacters = RegExp(
      r"[^\p{L}\s'-]",
      unicode: true,
    ).hasMatch(control.value!);

    return hasInvalidCharacters
        ? <String, dynamic>{'invalidCharacters': true}
        : null;
  }
}
