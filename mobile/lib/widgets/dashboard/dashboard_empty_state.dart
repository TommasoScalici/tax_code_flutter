import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';

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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final isDark = theme.brightness == Brightness.dark;

    final isSearching = _isSearching;

    final title =
        isSearching ? l10n.emptySearchTitle : l10n.emptyDashboardTitle;

    final description = isSearching
        ? l10n.emptySearchDescription(searchQuery!.trim())
        : l10n.emptyDashboardDescription;

    final icon = isSearching
        ? Icons.search_off_rounded
        : Icons.credit_card_off_rounded;

    final iconColor = isSearching ? colorScheme.primary : AppColors.emeraldPrimary;

    final iconContainerBg = isSearching
        ? colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.6 : 0.45,
          )
        : (isDark ? AppColors.emeraldContainerDark : AppColors.lightPrimaryContainer);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with soft glow / container background
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: iconContainerBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSearching
                        ? colorScheme.outlineVariant
                        : AppColors.emeraldBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (!isSearching)
                      BoxShadow(
                        color: AppColors.emeraldPrimary.withValues(
                          alpha: isDark ? 0.20 : 0.12,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Action button
              if (isSearching && onClearSearch != null)
                OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.emptySearchClearAction),
                )
              else if (!isSearching && onAddContact != null)
                FilledButton.icon(
                  onPressed: onAddContact,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(l10n.addCode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
