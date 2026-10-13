import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/cards/contact_card_action_buttons.dart';
import 'package:tax_code_flutter/widgets/cards/contact_card_anagraphics.dart';
import 'package:tax_code_flutter/widgets/cards/contact_card_header.dart';
import 'package:tax_code_flutter/widgets/cards/contact_card_tax_code_box.dart';

export 'package:tax_code_flutter/widgets/cards/contact_card_action_buttons.dart';
export 'package:tax_code_flutter/widgets/cards/contact_card_anagraphics.dart';
export 'package:tax_code_flutter/widgets/cards/contact_card_header.dart';
export 'package:tax_code_flutter/widgets/cards/contact_card_tax_code_box.dart';

/// Modern card widget displaying a saved Tax Code contact
/// following the Emerald Ledger design system.
///
/// Features:
/// - Distinctive card container with 20px rounded corners and subtle border.
/// - Contact full name and gender badge via [ContactCardHeader].
/// - Hero fiscal code box in `JetBrains Mono` with tap-to-copy via [ContactCardTaxCodeBox].
/// - Anagraphic details (birthplace, birthdate) via [ContactCardAnagraphics].
/// - 4 pill-shaped action buttons (Share, Barcode, Edit, Delete) via [ContactCardActionButtons].
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

  /// Creates a [ContactCard].
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

    final cardBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? AppOpacity.medium : AppOpacity.almostOpaque,
    );

    return Container(
      constraints: const BoxConstraints(
        maxWidth: AppDimensions.maxContentWidth,
      ),
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: cardBorderColor),
        boxShadow: [AppColors.shadowCard(isDark)],
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
              ContactCardHeader(contact: contact),
              const SizedBox(height: AppSpacing.md),
              ContactCardTaxCodeBox(
                taxCode: contact.taxCode,
                onTap: () => _copyTaxCode(context, l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              ContactCardAnagraphics(
                birthPlace: contact.birthPlace,
                birthDate: contact.birthDate,
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(
                height: 1,
                thickness: AppDimensions.borderDefault,
                color: colorScheme.outlineVariant.withValues(
                  alpha: AppOpacity.divider,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              ContactCardActionButtons(
                onShare: onShare,
                onShowBarcode: onShowBarcode,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward-compatible alias for [ContactCard].
typedef ModernContactCard = ContactCard;
