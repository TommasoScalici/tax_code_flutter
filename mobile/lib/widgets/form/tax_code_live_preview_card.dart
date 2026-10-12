import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// A card that dynamically previews the calculated Italian Tax Code (Codice Fiscale)
/// in real time as the user fills out the form.
///
/// Features JetBrains Mono monospaced typography, emerald glow when complete,
/// and tap-to-copy feedback.
class TaxCodeLivePreviewCard extends StatelessWidget {
  /// The currently calculated tax code, or null/empty if incomplete.
  final String? taxCode;

  /// Optional margin around the preview card.
  final EdgeInsetsGeometry? margin;

  /// Optional callback invoked after the code is successfully copied to clipboard.
  final VoidCallback? onCopied;

  const TaxCodeLivePreviewCard({
    super.key,
    required this.taxCode,
    this.margin,
    this.onCopied,
  });

  bool get _isComplete => taxCode != null && taxCode!.trim().length == 16;

  Future<void> _copyCode(BuildContext context, String code, AppLocalizations l10n) async {
    onCopied?.call();

    try {
      await Clipboard.setData(ClipboardData(text: code));
      await HapticFeedback.lightImpact();
    } on Object catch (_) {
      // Ignored in test / headless environments
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.taxCodeCopied),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedTitle = l10n.taxCodeLivePreviewTitle;
    final resolvedHint = l10n.taxCodeLivePreviewHint;

    final effectiveCode = (taxCode != null && taxCode!.isNotEmpty) ? taxCode!.toUpperCase() : null;

    final borderColor = _isComplete
        ? colorScheme.primary.withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.muted)
        : colorScheme.outlineVariant.withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.medium);

    final bgColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: borderColor),
        boxShadow: _isComplete
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: AppSpacing.lg,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadii.borderMd,
        child: InkWell(
          key: const Key('tax_code_live_preview_inkwell'),
          onTap: _isComplete ? () => _copyCode(context, effectiveCode!, l10n) : null,
          borderRadius: AppRadii.borderMd,
          child: Padding(
            padding: AppSpacing.paddingField,
            child: Row(
              children: [
                // Leading verified / calculation icon
                Container(
                  width: AppDimensions.avatarBadge,
                  height: AppDimensions.avatarBadge,
                  decoration: BoxDecoration(
                    color: _isComplete
                        ? colorScheme.primary.withValues(
                            alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.faint,
                          )
                        : colorScheme.surfaceContainerHighest.withValues(alpha: AppOpacity.divider),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isComplete ? Icons.verified_rounded : Icons.pending_rounded,
                    color: _isComplete ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Title & Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resolvedTitle.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.high),
                          fontSize: AppFontSizes.micro,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppLetterSpacing.badge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      if (effectiveCode != null)
                        Text(
                          effectiveCode,
                          style: AppTypography.codeDisplayCard(
                            color: _isComplete ? colorScheme.primary : colorScheme.onSurface,
                            fontSize: AppFontSizes.bodyLg,
                          ),
                        )
                      else
                        Text(
                          resolvedHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
                            fontStyle: FontStyle.italic,
                            fontSize: AppFontSizes.bodySm,
                          ),
                        ),
                    ],
                  ),
                ),

                // Copy Action Indicator
                if (_isComplete)
                  IconButton(
                    key: const Key('tax_code_live_preview_copy_button'),
                    icon: Icon(
                      Icons.copy_rounded,
                      size: AppDimensions.iconAction,
                      color: colorScheme.primary,
                    ),
                    tooltip: l10n.copyTaxCode,
                    onPressed: () => _copyCode(context, effectiveCode!, l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
