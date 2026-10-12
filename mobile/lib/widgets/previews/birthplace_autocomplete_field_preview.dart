import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_field.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [BirthplaceAutocompleteField] with sample mock birthplaces.
class BirthplaceAutocompleteFieldPreview extends StatefulWidget {
  @Preview(name: 'Birthplace Autocomplete Field')
  const BirthplaceAutocompleteFieldPreview({super.key});

  @override
  State<BirthplaceAutocompleteFieldPreview> createState() =>
      _BirthplaceAutocompleteFieldPreviewState();
}

class _BirthplaceAutocompleteFieldPreviewState
    extends State<BirthplaceAutocompleteFieldPreview> {
  final FocusNode _focusNode = FocusNode();

  static const List<Birthplace> _mockBirthplaces = [
    Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
    Birthplace(name: 'Napoli', state: 'NA', code: 'F839'),
    Birthplace(name: 'Torino', state: 'TO', code: 'L219'),
    Birthplace(name: 'Palermo', state: 'PA', code: 'G273'),
    Birthplace(name: 'Francia', state: 'EE', code: 'Z110'),
    Birthplace(name: 'Germania', state: 'EE', code: 'Z112'),
  ];

  Birthplace? _selectedBirthplace;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      builder: (context, isDarkMode) {
        final theme = Theme.of(context);
        final l10n = context.l10n;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BirthplaceAutocompleteField(
              birthplaces: _mockBirthplaces,
              focusNode: _focusNode,
              value: _selectedBirthplace,
              onChanged: (place) {
                setState(() {
                  _selectedBirthplace = place;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _selectedBirthplace != null
                  ? '${l10n.birthPlace}: ${_selectedBirthplace!.name} (${_selectedBirthplace!.state})'
                  : l10n.birthplacePlaceholder,
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
