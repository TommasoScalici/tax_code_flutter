import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/gender_segmented_button.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [GenderSegmentedButton] with interactive state
/// selection, error toggle, and theme switching.
class GenderSegmentedButtonPreview extends StatefulWidget {
  @Preview(name: 'Gender Segmented Button')
  const GenderSegmentedButtonPreview({super.key});

  @override
  State<GenderSegmentedButtonPreview> createState() =>
      _GenderSegmentedButtonPreviewState();
}

class _GenderSegmentedButtonPreviewState
    extends State<GenderSegmentedButtonPreview> {
  String? _selectedGender = 'M';
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      toolbarActions: (context, isDarkMode) {
        final l10n = context.l10n;
        return [
          FilterChip(
            label: Text(l10n.simulateError),
            selected: _showError,
            onSelected: (val) {
              setState(() {
                _showError = val;
              });
            },
          ),
        ];
      },
      builder: (context, isDarkMode) {
        final theme = Theme.of(context);
        final l10n = context.l10n;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GenderSegmentedButton(
              value: _selectedGender,
              onChanged: (newVal) {
                setState(() {
                  _selectedGender = newVal;
                });
              },
              errorText: _showError ? l10n.required : null,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.selectedValue(_selectedGender ?? l10n.none),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}
