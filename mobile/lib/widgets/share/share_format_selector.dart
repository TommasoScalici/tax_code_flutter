import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/share/contact_share_format.dart';
import 'package:tax_code_flutter/widgets/share/share_option_card.dart';

/// Segmented vertical option selector allowing the user to choose between
/// plain text, high-resolution PNG card, or printable A4 PDF format.
class ShareFormatSelector extends StatelessWidget {
  /// The currently selected format.
  final ContactShareFormat selectedFormat;

  /// Callback when a new format is tapped by the user.
  final ValueChanged<ContactShareFormat>? onFormatSelected;

  /// Whether format selection is enabled. If false, cards are non-interactive.
  final bool isEnabled;

  /// Creates a [ShareFormatSelector].
  const ShareFormatSelector({
    required this.selectedFormat,
    this.onFormatSelected,
    this.isEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option 1: Quick Text
        ShareOptionCard(
          key: const Key('share_format_text_card'),
          title: l10n.shareOptionTextTitle,
          description: l10n.shareOptionTextDesc,
          icon: Icons.text_fields_rounded,
          isSelected: selectedFormat == ContactShareFormat.text,
          onTap: isEnabled
              ? () => onFormatSelected?.call(ContactShareFormat.text)
              : null,
        ),
        const SizedBox(height: AppSpacing.compact),

        // Option 2: HD Card Image (PNG)
        ShareOptionCard(
          key: const Key('share_format_image_card'),
          title: l10n.shareOptionImageTitle,
          description: l10n.shareOptionImageDesc,
          icon: Icons.image_outlined,
          isSelected: selectedFormat == ContactShareFormat.image,
          onTap: isEnabled
              ? () => onFormatSelected?.call(ContactShareFormat.image)
              : null,
        ),
        const SizedBox(height: AppSpacing.compact),

        // Option 3: PDF Summary Sheet
        ShareOptionCard(
          key: const Key('share_format_pdf_card'),
          title: l10n.shareOptionPdfTitle,
          description: l10n.shareOptionPdfDesc,
          icon: Icons.picture_as_pdf_outlined,
          isSelected: selectedFormat == ContactShareFormat.pdf,
          onTap: isEnabled
              ? () => onFormatSelected?.call(ContactShareFormat.pdf)
              : null,
        ),
      ],
    );
  }
}
