import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// A modern, accessible Material 3 switch card for toggling whether
/// the tax code being created or edited belongs to the current user ("TU").
class IsMeSwitchField extends StatelessWidget {
  /// Reactive form control name when used inside a [ReactiveForm].
  final String formControlName;

  /// Optional name of another contact currently designated as primary, if any.
  final String? otherMeContactName;

  const IsMeSwitchField({
    super.key,
    required this.formControlName,
    this.otherMeContactName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveFormField<bool, bool>(
      formControlName: formControlName,
      builder: (field) {
        final isChecked = field.value ?? false;
        final showReplacesNotice =
            isChecked &&
            otherMeContactName != null &&
            otherMeContactName!.isNotEmpty;

        final containerBg = isChecked
            ? colorScheme.primaryContainer.withValues(
                alpha: isDark ? AppOpacity.translucent : 0.25,
              )
            : (isDark
                  ? colorScheme.surfaceContainer
                  : colorScheme.surfaceContainerLow);

        final borderColor = isChecked
            ? colorScheme.primary.withValues(
                alpha: isDark ? AppOpacity.prominent : 0.5,
              )
            : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.compact,
          ),
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: AppRadii.borderInput,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: AppDimensions.avatarSm,
                    height: AppDimensions.avatarSm,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.person_pin_rounded,
                      color: isChecked
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.isMeLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.isMeSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: AppLineHeights.relaxed,
                            fontSize: AppFontSizes.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Switch.adaptive(
                    key: const Key('is_me_switch'),
                    value: isChecked,
                    activeTrackColor: colorScheme.primary,
                    activeThumbColor: colorScheme.onPrimary,
                    onChanged: (val) {
                      field.didChange(val);
                      field.control.markAsTouched();
                    },
                  ),
                ],
              ),
              if (showReplacesNotice) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.compact,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: isDark ? AppOpacity.muted : AppOpacity.subtle,
                    ),
                    borderRadius: AppRadii.borderCompact,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppDimensions.iconXs,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.badgeGap),
                      Expanded(
                        child: Text(
                          l10n.isMeReplacesExisting(otherMeContactName!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                            fontSize: AppFontSizes.micro,
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
