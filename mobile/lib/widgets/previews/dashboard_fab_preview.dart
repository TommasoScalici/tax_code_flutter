import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [DashboardFab] within a centered mobile viewport.
class DashboardFabPreview extends StatefulWidget {
  @Preview(name: 'Dashboard FAB')
  const DashboardFabPreview({super.key});

  @override
  State<DashboardFabPreview> createState() => _DashboardFabPreviewState();
}

class _DashboardFabPreviewState extends State<DashboardFabPreview> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          FilterChip(
            label: Text(l10n.extended),
            selected: _isExtended,
            onSelected: (val) {
              setState(() {
                _isExtended = val;
              });
            },
          ),
        ];
      },
      builder: (context, _) {
        final l10n = context.l10n;
        return Card(
          child: Container(
            height: 200,
            alignment: Alignment.center,
            child: DashboardFab(
              isExtended: _isExtended,
              onPressed: () => PreviewShell.showFeedback(
                context,
                l10n.addCode,
              ),
            ),
          ),
        );
      },
    );
  }
}
