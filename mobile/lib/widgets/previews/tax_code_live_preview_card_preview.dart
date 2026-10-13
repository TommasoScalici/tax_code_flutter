import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/tax_code_live_preview_card.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [TaxCodeLivePreviewCard] with toggles for empty,
/// partial, and complete tax code states.
class TaxCodeLivePreviewCardPreview extends StatefulWidget {
  @Preview(name: 'Tax Code Live Preview Card')
  const TaxCodeLivePreviewCardPreview({super.key});

  @override
  State<TaxCodeLivePreviewCardPreview> createState() =>
      _TaxCodeLivePreviewCardPreviewState();
}

class _TaxCodeLivePreviewCardPreviewState
    extends State<TaxCodeLivePreviewCardPreview> {
  int _stateIndex = 2; // 0 = empty, 1 = partial, 2 = complete

  static const List<String?> _codes = [null, 'RSSMRA85D15', 'RSSMRA85D15H501Z'];

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 460,
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          ChoiceChip(
            label: Text(l10n.filterEmpty),
            selected: _stateIndex == 0,
            onSelected: (selected) {
              if (selected) setState(() => _stateIndex = 0);
            },
          ),
          ChoiceChip(
            label: Text(l10n.filterPartial),
            selected: _stateIndex == 1,
            onSelected: (selected) {
              if (selected) setState(() => _stateIndex = 1);
            },
          ),
          ChoiceChip(
            label: Text(l10n.filterComplete),
            selected: _stateIndex == 2,
            onSelected: (selected) {
              if (selected) setState(() => _stateIndex = 2);
            },
          ),
        ];
      },
      child: TaxCodeLivePreviewCard(taxCode: _codes[_stateIndex]),
    );
  }
}
