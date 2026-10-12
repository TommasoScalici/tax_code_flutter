import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [DashboardEmptyState] within a centered viewport.
class DashboardEmptyStatePreview extends StatefulWidget {
  @Preview(name: 'Dashboard Empty State')
  const DashboardEmptyStatePreview({super.key});

  @override
  State<DashboardEmptyStatePreview> createState() =>
      _DashboardEmptyStatePreviewState();
}

enum _EmptyStateScenario {
  noSavedCards,
  searchNoResults,
}

class _DashboardEmptyStatePreviewState
    extends State<DashboardEmptyStatePreview> {
  _EmptyStateScenario _scenario = _EmptyStateScenario.noSavedCards;
  static const String _searchQuery = 'Mario Rossi';

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 480,
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          ChoiceChip(
            label: Text(l10n.emptyDashboardTitle),
            selected: _scenario == _EmptyStateScenario.noSavedCards,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _scenario = _EmptyStateScenario.noSavedCards;
                });
              }
            },
          ),
          ChoiceChip(
            label: Text(l10n.emptySearchTitle),
            selected: _scenario == _EmptyStateScenario.searchNoResults,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _scenario = _EmptyStateScenario.searchNoResults;
                });
              }
            },
          ),
        ];
      },
      builder: (context, _) {
        final l10n = context.l10n;

        return DashboardEmptyState(
          searchQuery: _scenario == _EmptyStateScenario.searchNoResults
              ? _searchQuery
              : null,
          onClearSearch: () {
            PreviewShell.showFeedback(context, l10n.emptySearchClearAction);
            setState(() {
              _scenario = _EmptyStateScenario.noSavedCards;
            });
          },
          onAddContact: () {
            PreviewShell.showFeedback(context, l10n.addCode);
          },
        );
      },
    );
  }
}
