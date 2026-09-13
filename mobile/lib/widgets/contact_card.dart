import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';

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

  const ContactCard({
    super.key,
    required this.contact,
    required this.onShare,
    required this.onShowBarcode,
    required this.onEdit,
    required this.onDelete,
    this.onCopy,
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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final isDark = theme.brightness == Brightness.dark;

    final formattedBirthDate = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).format(contact.birthDate);

    final cardBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.7 : 0.9,
    );

    final taxCodeBoxBg = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Avatar circle, Full Name, Gender Chip
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.14 : 0.10,
                      ),
                      border: Border.all(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.30 : 0.20,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            contact.lastName,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.6 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
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
                  const SizedBox(width: 8),
                  Icon(
                    Icons.drag_indicator_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hero Tax Code Display Box with Tap-to-Copy
              Tooltip(
                triggerMode: TooltipTriggerMode.manual,
                message: l10n.copyTaxCode,
                child: Material(
                  color: taxCodeBoxBg,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    key: const Key('contact_card_tax_code_box'),
                    onTap: () => _copyTaxCode(context, l10n),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.emeraldBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
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
                          const SizedBox(width: 8),
                          Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: colorScheme.primary.withValues(alpha: 0.75),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Anagraphic Details Row (Birthplace, Birthdate, Gender)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
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
                    style: TextStyle(
                      color: colorScheme.outlineVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
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
              const SizedBox(height: 12),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 10),

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
                  const SizedBox(width: 6),
                  Expanded(
                    child: _CardActionButton(
                      icon: Symbols.barcode,
                      label: l10n.cardActionBarcode,
                      tooltip: l10n.tooltipShowBarcode,
                      onPressed: onShowBarcode,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _CardActionButton(
                      icon: Icons.edit,
                      label: l10n.cardActionEdit,
                      tooltip: l10n.tooltipEdit,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 6),
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
        ? colorScheme.error.withValues(alpha: isDark ? 0.12 : 0.08)
        : colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.5 : 0.45,
          );

    final fgColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final borderColor = isDestructive
        ? colorScheme.error.withValues(alpha: isDark ? 0.30 : 0.20)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Tooltip(
      triggerMode: TooltipTriggerMode.manual,
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: StadiumBorder(
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: fgColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
