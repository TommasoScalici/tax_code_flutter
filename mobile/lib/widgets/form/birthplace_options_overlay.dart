import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

/// Dropdown options overlay presenting matched municipalities and foreign countries.
class BirthplaceOptionsOverlay extends StatelessWidget {
  /// The collection of filtered birthplaces to display.
  final Iterable<Birthplace> options;

  /// Callback triggered when an option is selected by the user.
  final AutocompleteOnSelected<Birthplace> onSelected;

  const BirthplaceOptionsOverlay({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: AppElevation.level3,
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        borderRadius: AppRadii.borderMd,
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: AppDimensions.maxDropdownHeight,
            maxWidth: AppDimensions.maxDropdownWidth,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? AppOpacity.muted : AppOpacity.high,
              ),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.badgeGap),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: AppDimensions.borderHairline,
              color: colorScheme.outlineVariant.withValues(
                alpha: AppOpacity.translucent,
              ),
            ),
            itemBuilder: (context, index) {
              final birthplace = options.elementAt(index);
              final isForeign = birthplace.state == 'EE';

              return InkWell(
                onTap: () => onSelected(birthplace),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.compact,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isForeign
                            ? Icons.public_rounded
                            : Icons.location_city_rounded,
                        size: AppDimensions.iconAction,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          birthplace.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Province Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.badgeGap,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: isDark
                                ? AppOpacity.muted
                                : AppOpacity.outline,
                          ),
                          borderRadius: AppRadii.borderBadge,
                        ),
                        child: Text(
                          birthplace.state,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: AppFontSizes.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
