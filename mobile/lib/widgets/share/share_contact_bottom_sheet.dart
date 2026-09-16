import 'dart:io';

import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

/// Available formats for sharing a single contact's tax code data.
enum ContactShareFormat {
  /// Plain text tax code string.
  text,

  /// High-resolution graphical card with 1D Barcode and 2D QR Code.
  image,

  /// Printable A4 summary document with complete personal details.
  pdf,
}

/// Modal bottom sheet allowing users to share a contact via text,
/// high-resolution PNG card, or printable A4 PDF.
class ShareContactBottomSheet extends StatefulWidget {
  /// The contact to share.
  final Contact contact;

  /// Creates a [ShareContactBottomSheet].
  const ShareContactBottomSheet({
    required this.contact,
    super.key,
  });

  /// Displays the share contact sheet modally.
  static Future<void> show(
    BuildContext context, {
    required Contact contact,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.modalBarrier,
      builder: (_) => ShareContactBottomSheet(contact: contact),
    );
  }

  @override
  State<ShareContactBottomSheet> createState() =>
      _ShareContactBottomSheetState();
}

class _ShareContactBottomSheetState extends State<ShareContactBottomSheet> {
  ContactShareFormat _selectedFormat = ContactShareFormat.text;
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final sharingService = context.read<SharingServiceAbstract>();
      final contact = widget.contact;

      if (_selectedFormat == ContactShareFormat.text) {
        if (!mounted) return;
        Navigator.of(context).pop();
        await sharingService.share(text: contact.taxCode);
        return;
      }

      final l10n = context.l10n;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final imageService = context.read<ContactCardImageServiceAbstract>();
      final pdfService = context.read<ContactPdfServiceAbstract>();

      final tempDir = await getTemporaryDirectory();
      final sanitizedCode = contact.taxCode.isNotEmpty
          ? contact.taxCode
          : 'codice_fiscale';

      final contactName =
          '${contact.firstName} ${contact.lastName}'.trim().isNotEmpty
          ? '${contact.firstName} ${contact.lastName}'.trim()
          : contact.taxCode;

      late final File file;
      late final String mimeType;
      late final String subject;

      if (_selectedFormat == ContactShareFormat.image) {
        final bytes = await imageService.generateCardImage(
          contact: contact,
          l10n: l10n,
        );
        final fileName = 'tessera_$sanitizedCode.png';
        file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        mimeType = 'image/png';
        subject = l10n.shareCardSubject(contactName);
      } else {
        final bytes = await pdfService.generateContactPdf(
          contact: contact,
          l10n: l10n,
        );
        final fileName = 'scheda_$sanitizedCode.pdf';
        file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        mimeType = 'application/pdf';
        subject = l10n.sharePdfSubject(contactName);
      }

      if (!mounted) return;

      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareContactSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await sharingService.shareFile(
        filePath: file.path,
        mimeType: mimeType,
        subject: subject,
      );
    } on Object catch (e, s) {
      if (mounted) {
        final logger = context.read<Logger?>();
        logger?.e('Failed to share contact', error: e, stackTrace: s);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    final topBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.40 : 0.60,
    );

    final contact = widget.contact;
    final contactDisplayName =
        '${contact.firstName} ${contact.lastName}'.trim().isNotEmpty
        ? '${contact.firstName} ${contact.lastName}'.trim()
        : l10n.contactFallback;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: topBorderColor)),
            boxShadow: [
              AppColors.shadowSheet(isDark),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 12.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // M3 Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.40,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.shareContactTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                  const SizedBox(height: 16),

                  // Contact Summary Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contactDisplayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          contact.taxCode,
                          style: AppTypography.codeDisplay(
                            color: colorScheme.primary,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Option 1: Quick Text
                  _ShareOptionCard(
                    key: const Key('share_format_text_card'),
                    title: l10n.shareOptionTextTitle,
                    description: l10n.shareOptionTextDesc,
                    icon: Icons.text_fields_rounded,
                    isSelected: _selectedFormat == ContactShareFormat.text,
                    onTap: _isSharing
                        ? null
                        : () => setState(
                            () => _selectedFormat = ContactShareFormat.text,
                          ),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: HD Card Image (PNG)
                  _ShareOptionCard(
                    key: const Key('share_format_image_card'),
                    title: l10n.shareOptionImageTitle,
                    description: l10n.shareOptionImageDesc,
                    icon: Icons.image_outlined,
                    isSelected: _selectedFormat == ContactShareFormat.image,
                    onTap: _isSharing
                        ? null
                        : () => setState(
                            () => _selectedFormat = ContactShareFormat.image,
                          ),
                  ),
                  const SizedBox(height: 10),

                  // Option 3: PDF Summary Sheet
                  _ShareOptionCard(
                    key: const Key('share_format_pdf_card'),
                    title: l10n.shareOptionPdfTitle,
                    description: l10n.shareOptionPdfDesc,
                    icon: Icons.picture_as_pdf_outlined,
                    isSelected: _selectedFormat == ContactShareFormat.pdf,
                    onTap: _isSharing
                        ? null
                        : () => setState(
                            () => _selectedFormat = ContactShareFormat.pdf,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          key: const Key('share_cancel_button'),
                          onPressed: _isSharing
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          key: const Key('share_confirm_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          onPressed: _isSharing ? null : _handleShare,
                          icon: _isSharing
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.share_rounded, size: 20),
                          label: Text(
                            l10n.shareContactAction,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareOptionCard extends StatelessWidget {
  const _ShareOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(
            alpha: isDark ? 0.12 : 0.06,
          )
        : theme.colorScheme.surfaceContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(
                        alpha: isDark ? 0.22 : 0.12,
                      )
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
