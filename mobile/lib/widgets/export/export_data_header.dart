import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Top header section for `ExportDataBottomSheet`, displaying the modal drag handle,
/// descriptive title with download icon, close button, and dynamic contact count badge.
class ExportDataHeader extends StatelessWidget {
  /// Number of saved contacts available for export.
  final int contactCount;

  /// Callback when the close icon button is tapped.
  final VoidCallback? onClose;

  /// Creates an [ExportDataHeader].
  const ExportDataHeader({required this.contactCount, this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final hasContacts = contactCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: AppDimensions.dragHandleWidth,
            height: AppDimensions.dragHandleHeight,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: AppOpacity.outline,
              ),
              borderRadius: AppRadii.borderHandle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Title row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.compact),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_download_outlined,
                color: theme.colorScheme.primary,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppSpacing.fieldVertical),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exportDataTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: AppLetterSpacing.titleTight,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.exportDataSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('export_sheet_close_button'),
              icon: const Icon(Icons.close_rounded),
              onPressed: onClose ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.iconAction),

        // Contact count badge / empty state
        if (!hasContacts)
          Container(
            padding: const EdgeInsets.all(AppSpacing.fieldVertical),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(
                alpha: AppOpacity.translucent,
              ),
              borderRadius: AppRadii.borderInput,
              border: Border.all(
                color: theme.colorScheme.error.withValues(
                  alpha: AppOpacity.divider,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.error,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.exportNoCodes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.fieldVertical,
              vertical: AppSpacing.compact,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: AppRadii.borderInput,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: AppDimensions.iconAction,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.compact),
                Expanded(
                  child: Text(
                    l10n.exportCodesCount(contactCount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
