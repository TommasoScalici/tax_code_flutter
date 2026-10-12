import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Hero display container for the tax code in `ContactCard`, styled in monospace
/// with tap-to-copy interaction and visual emerald accent borders.
class ContactCardTaxCodeBox extends StatelessWidget {
  /// The tax code string to display.
  final String taxCode;

  /// Callback when the box is tapped to copy the tax code.
  final VoidCallback onTap;

  /// Creates a [ContactCardTaxCodeBox].
  const ContactCardTaxCodeBox({
    required this.taxCode,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final taxCodeBoxBg = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(
            alpha: AppOpacity.disabled,
          );

    return Tooltip(
      triggerMode: TooltipTriggerMode.manual,
      message: l10n.copyTaxCode,
      child: Material(
        color: taxCodeBoxBg,
        borderRadius: AppRadii.borderInput,
        child: InkWell(
          key: const Key('contact_card_tax_code_box'),
          onTap: onTap,
          borderRadius: AppRadii.borderInput,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.fieldVertical,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadii.borderInput,
              border: Border.all(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? AppOpacity.subtleBorder : AppOpacity.disabled,
                ),
                width: AppDimensions.borderMedium,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card_rounded,
                  size: AppDimensions.iconMd,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      taxCode,
                      style: AppTypography.codeDisplayCard(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.copy_rounded,
                  size: AppDimensions.iconAction,
                  color: colorScheme.primary.withValues(
                    alpha: AppOpacity.prominent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
