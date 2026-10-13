import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Top header section for `ShareContactBottomSheet`, displaying the modal drag handle,
/// descriptive title with icon, and a concise summary badge of the contact being shared.
class ShareContactHeader extends StatelessWidget {
  /// The contact whose data is being shared.
  final Contact contact;

  /// Creates a [ShareContactHeader].
  const ShareContactHeader({required this.contact, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final contactDisplayName =
        '${contact.firstName} ${contact.lastName}'.trim().isNotEmpty
        ? '${contact.firstName} ${contact.lastName}'.trim()
        : l10n.contactFallback;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // M3 Drag Handle
        Center(
          child: Container(
            width: AppDimensions.dragHandleWidth,
            height: AppDimensions.dragHandleHeight,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(
                alpha: AppOpacity.outline,
              ),
              borderRadius: AppRadii.borderHandle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Header Title Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.compact),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                color: colorScheme.primary,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppSpacing.fieldVertical),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shareContactTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: AppLetterSpacing.titleTight,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.shareContactSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Contact Summary Card
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.fieldVertical,
            vertical: AppSpacing.compact,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: AppRadii.borderInput,
          ),
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: AppDimensions.iconAction,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.compact),
              Expanded(
                child: Text(
                  contactDisplayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                contact.taxCode,
                style: AppTypography.codeDisplay(
                  color: colorScheme.primary,
                  fontSize: AppFontSizes.bodyMd,
                  letterSpacing: AppLetterSpacing.code,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
