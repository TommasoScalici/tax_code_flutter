import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/widgets/form/birthdate_picker_field.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [BirthdatePickerField] with Dark/Light toggle and date selection.
class BirthdatePickerFieldPreview extends StatefulWidget {
  @Preview(name: 'Birthdate Picker Field')
  const BirthdatePickerFieldPreview({super.key});

  @override
  State<BirthdatePickerFieldPreview> createState() =>
      _BirthdatePickerFieldPreviewState();
}

class _BirthdatePickerFieldPreviewState
    extends State<BirthdatePickerFieldPreview> {
  DateTime? _selectedDate = DateTime(1985, 4, 15);

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      builder: (context, isDarkMode) => BirthdatePickerField(
        value: _selectedDate,
        onChanged: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }
}
