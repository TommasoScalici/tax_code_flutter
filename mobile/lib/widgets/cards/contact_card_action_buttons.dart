import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Row of pill-shaped action buttons (Share, Barcode, Edit, Delete) for `ContactCard`.
class ContactCardActionButtons extends StatelessWidget {
  /// Callback when the share action is tapped.
  final VoidCallback onShare;

  /// Callback when the barcode visualizer action is tapped.
  final VoidCallback onShowBarcode;

  /// Callback when the edit action is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete action is tapped.
  final VoidCallback onDelete;

  /// Creates a [ContactCardActionButtons].
  const ContactCardActionButtons({
    required this.onShare,
    required this.onShowBarcode,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: CardActionButton(
            icon: Icons.share,
            label: l10n.share,
            tooltip: l10n.tooltipShare,
            onPressed: onShare,
          ),
        ),
        const SizedBox(width: AppSpacing.badgeGap),
        Expanded(
          child: CardActionButton(
            icon: Symbols.barcode,
            label: l10n.cardActionBarcode,
            tooltip: l10n.tooltipShowBarcode,
            onPressed: onShowBarcode,
          ),
        ),
        const SizedBox(width: AppSpacing.badgeGap),
        Expanded(
          child: CardActionButton(
            icon: Icons.edit,
            label: l10n.cardActionEdit,
            tooltip: l10n.tooltipEdit,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.badgeGap),
        Expanded(
          child: CardActionButton(
            icon: Icons.delete,
            label: l10n.cardActionDelete,
            tooltip: l10n.tooltipDelete,
            isDestructive: true,
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

/// Compact pill-shaped button designed specifically for contact card quick actions.
class CardActionButton extends StatelessWidget {
  /// Icon representing the action.
  final IconData icon;

  /// Localized text label.
  final String label;

  /// Tooltip message.
  final String tooltip;

  /// Callback when the button is tapped.
  final VoidCallback onPressed;

  /// Whether this action represents a destructive operation (e.g. Delete).
  final bool isDestructive;

  /// Creates a [CardActionButton].
  const CardActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.isDestructive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDestructive
        ? colorScheme.error.withValues(
            alpha: isDark ? AppOpacity.faint : AppOpacity.tint,
          )
        : colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? AppOpacity.divider : AppOpacity.outline,
          );

    final fgColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final borderColor = isDestructive
        ? colorScheme.error.withValues(
            alpha: isDark ? AppOpacity.translucent : AppOpacity.glow,
          )
        : colorScheme.outlineVariant.withValues(alpha: AppOpacity.divider);

    return Tooltip(
      triggerMode: TooltipTriggerMode.manual,
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppDimensions.iconSm, color: fgColor),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.caption,
                    ),
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
