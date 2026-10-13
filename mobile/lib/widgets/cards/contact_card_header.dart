import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

/// Top header section for `ContactCard`, featuring a circular avatar,
/// contact full name, gender pill badge, and drag handle icon.
class ContactCardHeader extends StatelessWidget {
  /// The contact whose personal details are displayed.
  final Contact contact;

  /// Creates a [ContactCardHeader].
  const ContactCardHeader({required this.contact, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: AppDimensions.avatarSm,
          height: AppDimensions.avatarSm,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary.withValues(
              alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(
                alpha: isDark ? AppOpacity.translucent : AppOpacity.glow,
              ),
            ),
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.primary,
            size: AppDimensions.iconMd,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  contact.firstName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontSize: AppFontSizes.bodyLg,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.badgeGap),
              Flexible(
                child: Text(
                  contact.lastName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontSize: AppFontSizes.bodyLg,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? AppOpacity.muted : AppOpacity.subtle,
            ),
            borderRadius: AppRadii.borderSm,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: AppOpacity.subtle,
              ),
            ),
          ),
          child: Text(
            contact.gender,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(
          Icons.drag_indicator_rounded,
          size: AppDimensions.iconAction,
          color: colorScheme.onSurfaceVariant.withValues(
            alpha: AppOpacity.outline,
          ),
        ),
      ],
    );
  }
}
