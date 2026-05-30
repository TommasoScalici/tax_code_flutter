import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';

class BirthplaceAutocomplete extends StatelessWidget {
  final String formControlName;
  final FocusNode focusNode;
  final String labelText;
  final String requiredMessage;
  final List<Birthplace> birthplaces;

  const BirthplaceAutocomplete({
    super.key,
    required this.formControlName,
    required this.focusNode,
    required this.labelText,
    required this.requiredMessage,
    required this.birthplaces,
  });

  @override
  Widget build(BuildContext context) {
    final formGroup = ReactiveForm.of(context) as FormGroup?;
    final control = formGroup?.control(formControlName) as FormControl<dynamic>?;

    return ReactiveRawAutocomplete<Birthplace, Birthplace>(
      formControlName: formControlName,
      focusNode: focusNode,
      validationMessages: {
        ValidationMessage.required: (error) => requiredMessage,
      },
      optionsBuilder: (TextEditingValue value) {
        if (value.text.length < 2) {
          return const Iterable<Birthplace>.empty();
        }
        return birthplaces
            .where(
              (b) => b.name.toLowerCase().contains(
                    value.text.toLowerCase(),
                  ),
            )
            .take(20)
            .toList();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return ReactiveValueListenableBuilder<dynamic>(
          formControl: control,
          builder: (context, currentControl, child) {
            final errorText =
                currentControl.invalid && currentControl.touched ? requiredMessage : null;

            return TextField(
              controller: textEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: labelText,
                errorText: errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    if (control != null) {
                      control.value = null;
                      control.markAsTouched();
                    }
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            );
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        void Function(Birthplace) onSelected,
        Iterable<Birthplace> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 240,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final birthplace = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(birthplace);
                      FocusScope.of(context).unfocus();
                    },
                    child: ListTile(
                      title: Text(
                        '${birthplace.name} (${birthplace.state})',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
