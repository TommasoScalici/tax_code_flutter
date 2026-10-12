import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Header section of the barcode bottom sheet.
///
/// Displays the contact's avatar badge, full name, monospace tax code chip,
/// and a quick copy-to-clipboard button.
class BarcodeHeader extends StatelessWidget {
  /// The contact whose identity and tax code are displayed.
  final Contact contact;

  /// Callback invoked when the user taps the quick copy button.
  final VoidCallback onCopy;

  const BarcodeHeader({
    super.key,
    required this.contact,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Badge Avatar
        Container(
          width: AppDimensions.iconDisplay,
          height: AppDimensions.iconDisplay,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(
              alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.faint,
            ),
            borderRadius: AppRadii.borderInner,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: AppOpacity.translucent),
            ),
          ),
          child: Icon(
            Icons.badge_rounded,
            color: colorScheme.primary,
            size: AppDimensions.iconButton,
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Name, Tax Code Chip, and Copy Action
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${contact.firstName} ${contact.lastName}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.headlineSm,
                ),
              ),
              const SizedBox(height: AppSpacing.badgeGap),
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingBadge,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
                      ),
                      borderRadius: AppRadii.borderBadge,
                      border: Border.all(
                        color: colorScheme.primary.withValues(
                          alpha: AppOpacity.disabled,
                        ),
                      ),
                    ),
                    child: Text(
                      contact.taxCode,
                      style: AppTypography.codeDisplay(
                        color: colorScheme.primary,
                        fontSize: AppFontSizes.titleSm,
                        letterSpacing: AppLetterSpacing.codeCompact,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  InkWell(
                    key: const Key('barcode_bottom_sheet_copy_button'),
                    onTap: onCopy,
                    borderRadius: AppRadii.borderCard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.compact,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: AppOpacity.muted,
                              ),
                        borderRadius: AppRadii.borderCard,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: AppOpacity.divider,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: AppDimensions.iconXs,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.copyAction,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
