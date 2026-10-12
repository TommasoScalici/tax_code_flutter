import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Modern card widget displaying a saved Tax Code contact
/// following the Emerald Ledger design system.
///
/// Features:
/// - Distinctive card container with 20px rounded corners and subtle border.
/// - Contact full name and gender badge.
/// - Hero fiscal code box in `JetBrains Mono` with tap-to-copy and emerald accent.
/// - Anagraphic details (birthplace, birthdate, gender) in muted typography.
/// - 4 pill-shaped action buttons: Share, Barcode, Edit, Delete.
class ContactCard extends StatelessWidget {
  /// The contact whose tax code details are displayed.
  final Contact contact;

  /// Callback when the share action is tapped.
  final VoidCallback onShare;

  /// Callback when the barcode visualizer action is tapped.
  final VoidCallback onShowBarcode;

  /// Callback when the edit action is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete action is tapped.
  final VoidCallback onDelete;

  /// Optional callback invoked when the tax code is copied to the clipboard.
  final VoidCallback? onCopy;

  /// Optional margin around the card container. Defaults to [EdgeInsets.symmetric(vertical: 4.0)].
  final EdgeInsetsGeometry? margin;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onShare,
    required this.onShowBarcode,
    required this.onEdit,
    required this.onDelete,
    this.onCopy,
    this.margin,
  });

  Future<void> _copyTaxCode(BuildContext context, AppLocalizations l10n) async {
    onCopy?.call();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.taxCodeCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      await Clipboard.setData(ClipboardData(text: contact.taxCode));
      await HapticFeedback.lightImpact();
    } on Exception {
      // Ignored in headless/test environments where platform channels may not be bound
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final formattedBirthDate = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).format(contact.birthDate);

    final cardBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? AppOpacity.medium : AppOpacity.almostOpaque,
    );

    final taxCodeBoxBg = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(alpha: AppOpacity.disabled);

    return Container(
      constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          AppColors.shadowCard(isDark),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadii.borderCard,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Avatar circle, Full Name, Gender Chip
              Row(
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
                        alpha: isDark ? 0.6 : AppOpacity.subtle,
                      ),
                      borderRadius: AppRadii.borderSm,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: AppOpacity.subtle),
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
                    color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.outline),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Hero Tax Code Display Box with Tap-to-Copy
              Tooltip(
                triggerMode: TooltipTriggerMode.manual,
                message: l10n.copyTaxCode,
                child: Material(
                  color: taxCodeBoxBg,
                  borderRadius: AppRadii.borderInput,
                  child: InkWell(
                    key: const Key('contact_card_tax_code_box'),
                    onTap: () => _copyTaxCode(context, l10n),
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
                                contact.taxCode,
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
                            color: colorScheme.primary.withValues(alpha: AppOpacity.prominent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Anagraphic Details Row (Birthplace, Birthdate, Gender)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: AppDimensions.iconXs,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        contact.birthPlace.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outlineVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: AppDimensions.iconXs,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formattedBirthDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Divider
              Divider(
                height: 1,
                thickness: AppDimensions.borderDefault,
                color: colorScheme.outlineVariant.withValues(alpha: AppOpacity.divider),
              ),
              const SizedBox(height: AppSpacing.compact),

              // 4 Action Buttons Pill Row
              Row(
                children: [
                  Expanded(
                    child: _CardActionButton(
                      icon: Icons.share,
                      label: l10n.share,
                      tooltip: l10n.tooltipShare,
                      onPressed: onShare,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.badgeGap),
                  Expanded(
                    child: _CardActionButton(
                      icon: Symbols.barcode,
                      label: l10n.cardActionBarcode,
                      tooltip: l10n.tooltipShowBarcode,
                      onPressed: onShowBarcode,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.badgeGap),
                  Expanded(
                    child: _CardActionButton(
                      icon: Icons.edit,
                      label: l10n.cardActionEdit,
                      tooltip: l10n.tooltipEdit,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.badgeGap),
                  Expanded(
                    child: _CardActionButton(
                      icon: Icons.delete,
                      label: l10n.cardActionDelete,
                      tooltip: l10n.tooltipDelete,
                      isDestructive: true,
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact pill-shaped button designed specifically for contact card quick actions.
class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDestructive
        ? colorScheme.error.withValues(alpha: isDark ? AppOpacity.faint : AppOpacity.tint)
        : colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? AppOpacity.divider : AppOpacity.outline,
          );

    final fgColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final borderColor = isDestructive
        ? colorScheme.error.withValues(alpha: isDark ? AppOpacity.translucent : AppOpacity.glow)
        : colorScheme.outlineVariant.withValues(alpha: AppOpacity.divider);

    return Tooltip(
      triggerMode: TooltipTriggerMode.manual,
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: StadiumBorder(
          side: BorderSide(color: borderColor),
        ),
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

/// Backward-compatible alias for [ContactCard].
typedef ModernContactCard = ContactCard;
