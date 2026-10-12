import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/widgets/form/form_section_divider.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [FormSectionDivider] with dark/light mode toggle.
class FormSectionDividerPreview extends StatelessWidget {
  @Preview(name: 'Form Section Divider')
  const FormSectionDividerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreviewShell(
      maxWidth: 480,
      child: FormSectionDivider(),
    );
  }
}
