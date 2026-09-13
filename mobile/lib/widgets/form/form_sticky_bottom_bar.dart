import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

/// A sticky bottom action bar containing the primary full-width "Salva Codice" button,
/// styled with emerald primary fill, calculate icon, and loading state.
class FormStickyBottomBar extends StatelessWidget {
  /// Callback when the save button is tapped.
  final VoidCallback? onSavePressed;

  /// Optional alias callback for [onSavePressed].
  final VoidCallback? onPressed;

  /// Whether the save button is enabled.
  final bool isEnabled;

  /// Whether a save or network operation is in progress.
  final bool isLoading;

  /// Optional custom label text.
  final String? labelText;

  /// Optional custom icon. Defaults to [Icons.calculate_rounded].
  final IconData icon;

  const FormStickyBottomBar({
    super.key,
    this.onSavePressed,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.labelText,
    this.icon = Icons.calculate_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedLabel = labelText ?? l10n?.saveCode ?? 'Salva Codice';

    final topBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.40 : 0.60,
    );

    final bgColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.95)
        : colorScheme.surface.withValues(alpha: 0.98);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: topBorderColor, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const Key('form_sticky_bottom_bar_button'),
                  onPressed: isEnabled && !isLoading ? (onSavePressed ?? onPressed) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              resolvedLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isEnabled
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
