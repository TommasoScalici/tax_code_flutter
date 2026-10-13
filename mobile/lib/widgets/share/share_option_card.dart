import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

/// Interactive card tile representing an individual export/share format option.
class ShareOptionCard extends StatelessWidget {
  /// The title of the share format option.
  final String title;

  /// The descriptive explanation of what this format produces.
  final String description;

  /// The icon representing the format.
  final IconData icon;

  /// Whether this format option is currently selected.
  final bool isSelected;

  /// Callback when this option is selected. If null, interaction is disabled.
  final VoidCallback? onTap;

  /// Creates a [ShareOptionCard].
  const ShareOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(
            alpha: isDark ? AppOpacity.faint : AppOpacity.tint,
          )
        : theme.colorScheme.surfaceContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingField,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.borderMd,
          border: Border.all(
            color: borderColor,
            width: isSelected
                ? AppDimensions.borderSelected
                : AppDimensions.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(
                        alpha: isDark
                            ? AppOpacity.subtleBorder
                            : AppOpacity.faint,
                      )
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppRadii.borderCompact,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconButton,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.fieldVertical),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
