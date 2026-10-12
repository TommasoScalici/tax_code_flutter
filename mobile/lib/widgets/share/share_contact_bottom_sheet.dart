import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/share/contact_share_file_helper.dart';
import 'package:tax_code_flutter/widgets/share/contact_share_format.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_header.dart';
import 'package:tax_code_flutter/widgets/share/share_format_selector.dart';

export 'package:tax_code_flutter/widgets/share/contact_share_file_helper.dart';
export 'package:tax_code_flutter/widgets/share/contact_share_format.dart';
export 'package:tax_code_flutter/widgets/share/share_contact_header.dart';
export 'package:tax_code_flutter/widgets/share/share_format_selector.dart';
export 'package:tax_code_flutter/widgets/share/share_option_card.dart';

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

      final exportResult = await ContactShareFileHelper.prepareExportFile(
        contact: contact,
        format: _selectedFormat,
        imageService: imageService,
        pdfService: pdfService,
        l10n: l10n,
      );

      if (!mounted) return;

      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareContactSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await sharingService.shareFile(
        filePath: exportResult.file.path,
        mimeType: exportResult.mimeType,
        subject: exportResult.subject,
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
      alpha: isDark ? AppOpacity.outline : AppOpacity.muted,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: AppRadii.borderSheet,
            border: Border(top: BorderSide(color: topBorderColor)),
            boxShadow: [
              AppColors.shadowSheet(isDark),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.card,
                right: AppSpacing.card,
                top: AppSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShareContactHeader(contact: widget.contact),
                  const SizedBox(height: AppDimensions.iconAction),
                  ShareFormatSelector(
                    selectedFormat: _selectedFormat,
                    isEnabled: !_isSharing,
                    onFormatSelected: (format) {
                      setState(() => _selectedFormat = format);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          key: const Key('share_confirm_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: AppSpacing.paddingFieldVertical,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.borderInput,
                            ),
                          ),
                          onPressed: _isSharing ? null : _handleShare,
                          icon: _isSharing
                              ? SizedBox(
                                  width: AppDimensions.iconAction,
                                  height: AppDimensions.iconAction,
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        AppDimensions.progressStrokeWidth,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.share_rounded,
                                  size: AppDimensions.iconMd,
                                ),
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
