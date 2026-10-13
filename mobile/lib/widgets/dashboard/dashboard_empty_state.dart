import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Modern empty state widget for the tax codes dashboard.
///
/// Handles two primary scenarios:
/// 1. **Search Empty**: When a user's active search query yields 0 matching contacts.
///    Provides a reset / clear action button.
/// 2. **Dashboard Empty**: When the user has not saved any tax codes yet.
///    Provides a call-to-action button to create the first tax code.
class DashboardEmptyState extends StatelessWidget {
  /// The active search query string, if any.
  final String? searchQuery;

  /// Callback to clear the active search filter.
  final VoidCallback? onClearSearch;

  /// Callback to trigger the creation of a new tax code.
  final VoidCallback? onAddContact;

  const DashboardEmptyState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
    this.onAddContact,
  });

  bool get _isSearching =>
      searchQuery != null && searchQuery!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final isSearching = _isSearching;

    final title = isSearching
        ? l10n.emptySearchTitle
        : l10n.emptyDashboardTitle;

    final description = isSearching
        ? l10n.emptySearchDescription(searchQuery!.trim())
        : l10n.emptyDashboardDescription;

    final icon = isSearching
        ? Icons.search_off_rounded
        : Icons.credit_card_off_rounded;

    final iconColor = colorScheme.primary;

    final iconContainerBg = isSearching
        ? colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.6 : 0.45,
          )
        : colorScheme.primaryContainer;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxEmptyStateWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with soft glow / container background
              Container(
                width: AppDimensions.iconIllustrationContainer,
                height: AppDimensions.iconIllustrationContainer,
                decoration: BoxDecoration(
                  color: iconContainerBg,
                  borderRadius: AppRadii.borderDialog,
                  border: Border.all(
                    color: isSearching
                        ? colorScheme.outlineVariant
                        : colorScheme.primary.withValues(
                            alpha: isDark
                                ? AppOpacity.subtleBorder
                                : AppOpacity.disabled,
                          ),
                    width: AppDimensions.borderMedium,
                  ),
                  boxShadow: [
                    if (!isSearching)
                      BoxShadow(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? AppOpacity.glow : AppOpacity.faint,
                        ),
                        blurRadius: AppSpacing.card,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconDisplay,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontSize: AppFontSizes.headlineMd,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Action button
              if (isSearching && onClearSearch != null)
                OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: AppDimensions.iconAction,
                  ),
                  label: Text(l10n.emptySearchClearAction),
                )
              else if (!isSearching && onAddContact != null)
                FilledButton.icon(
                  onPressed: onAddContact,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: AppDimensions.iconMd,
                  ),
                  label: Text(l10n.addCode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
