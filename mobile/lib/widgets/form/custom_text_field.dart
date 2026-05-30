import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomTextField extends StatelessWidget {
  final String formControlName;
  final String labelText;
  final TextInputAction textInputAction;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const CustomTextField({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.textInputAction = TextInputAction.next,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      formControlName: formControlName,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textInputAction: textInputAction,
      validationMessages: validationMessages,
    );
  }
}
