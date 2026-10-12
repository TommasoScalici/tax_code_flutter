import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [DashboardSearchBar] within a centered mobile viewport.
class DashboardSearchBarPreview extends StatefulWidget {
  @Preview(name: 'Dashboard Search Bar')
  const DashboardSearchBarPreview({super.key});

  @override
  State<DashboardSearchBarPreview> createState() =>
      _DashboardSearchBarPreviewState();
}

class _DashboardSearchBarPreviewState extends State<DashboardSearchBarPreview> {
  final TextEditingController _searchController = TextEditingController();
  int _cardCount = 3;
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          ChoiceChip(
            label: Text(l10n.savedCardsCount(0)),
            selected: _cardCount == 0,
            onSelected: (val) {
              if (val) setState(() => _cardCount = 0);
            },
          ),
          ChoiceChip(
            label: Text(l10n.savedCardsCount(1)),
            selected: _cardCount == 1,
            onSelected: (val) {
              if (val) setState(() => _cardCount = 1);
            },
          ),
          ChoiceChip(
            label: Text(l10n.savedCardsCount(3)),
            selected: _cardCount == 3,
            onSelected: (val) {
              if (val) setState(() => _cardCount = 3);
            },
          ),
        ];
      },
      builder: (context, isDarkMode) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              AppColors.shadowElevated(isDarkMode),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSearchBar(
                controller: _searchController,
                cardCount: _cardCount,
                onChanged: (text) => setState(() => _currentQuery = text),
                onClear: () => setState(() => _currentQuery = ''),
              ),
              if (_currentQuery.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: AppDimensions.iconXs,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Filtro: "$_currentQuery"',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
