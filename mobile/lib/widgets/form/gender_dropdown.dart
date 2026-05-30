import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GenderDropdown extends StatelessWidget {
  final String formControlName;
  final String labelText;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const GenderDropdown({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveDropdownField<String>(
      formControlName: formControlName,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      items: const [
        DropdownMenuItem(
          value: 'M',
          child: Text('M'),
        ),
        DropdownMenuItem(
          value: 'F',
          child: Text('F'),
        ),
      ],
      validationMessages: validationMessages,
    );
  }
}
