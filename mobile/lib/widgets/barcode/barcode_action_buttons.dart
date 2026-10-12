import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Action buttons row displayed at the bottom of the barcode modal sheet.
///
/// Houses the secondary "Close" action and the prominent primary "Share" action.
class BarcodeActionButtons extends StatelessWidget {
  /// Callback triggered when tapping the close button.
  final VoidCallback onClose;

  /// Callback triggered when tapping the share button.
  final VoidCallback onShare;

  const BarcodeActionButtons({
    super.key,
    required this.onClose,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        // Close Button
        Expanded(
          child: SizedBox(
            height: AppDimensions.minTouchTarget,
            child: OutlinedButton.icon(
              key: const Key('barcode_bottom_sheet_close_button'),
              onPressed: onClose,
              icon: const Icon(
                Icons.expand_more_rounded,
                size: AppDimensions.iconMd,
              ),
              label: Text(
                l10n.close,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.borderDialog,
                ),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: AppOpacity.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Share Button
        Expanded(
          child: SizedBox(
            height: AppDimensions.minTouchTarget,
            child: FilledButton.icon(
              key: const Key('barcode_bottom_sheet_share_button'),
              onPressed: onShare,
              icon: const Icon(
                Icons.share_rounded,
                size: AppDimensions.iconAction,
              ),
              label: Text(
                l10n.share,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.borderDialog,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
