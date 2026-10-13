import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/form_sticky_bottom_bar.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [FormStickyBottomBar] with interactive states
/// (enabled, disabled, loading, theme toggle).
class FormStickyBottomBarPreview extends StatefulWidget {
  @Preview(name: 'Form Sticky Bottom Bar')
  const FormStickyBottomBarPreview({super.key});

  @override
  State<FormStickyBottomBarPreview> createState() =>
      _FormStickyBottomBarPreviewState();
}

class _FormStickyBottomBarPreviewState
    extends State<FormStickyBottomBarPreview> {
  bool _isEnabled = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      expandChild: true,
      maxWidth: null,
      padding: EdgeInsets.zero,
      toolbarActions: (context, isDarkMode) {
        final l10n = context.l10n;
        return [
          FilterChip(
            label: Text(l10n.enabledStatus),
            selected: _isEnabled,
            onSelected: (val) {
              setState(() {
                _isEnabled = val;
              });
            },
          ),
          FilterChip(
            label: Text(l10n.loadingStatus),
            selected: _isLoading,
            onSelected: (val) {
              setState(() {
                _isLoading = val;
              });
            },
          ),
        ];
      },
      builder: (context, isDarkMode) {
        return Column(
          children: [
            const Spacer(),
            FormStickyBottomBar(
              isEnabled: _isEnabled,
              isLoading: _isLoading,
              onPressed: _isEnabled
                  ? () => PreviewShell.showFeedback(
                      context,
                      context.l10n.savingCodeInProgress,
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
