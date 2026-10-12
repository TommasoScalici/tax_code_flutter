import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_file_helper.dart';
import 'package:tax_code_flutter/widgets/export/export_data_header.dart';
import 'package:tax_code_flutter/widgets/export/export_format_selector.dart';

export 'package:tax_code_flutter/widgets/export/export_data_file_helper.dart';
export 'package:tax_code_flutter/widgets/export/export_data_header.dart';
export 'package:tax_code_flutter/widgets/export/export_format_option_card.dart';
export 'package:tax_code_flutter/widgets/export/export_format_selector.dart';

/// Modal bottom sheet allowing users to export their saved contacts
/// as either JSON or CSV offline backup files.
class ExportDataBottomSheet extends StatefulWidget {
  /// Creates an [ExportDataBottomSheet].
  const ExportDataBottomSheet({super.key});

  /// Displays the export bottom sheet modally.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColors.transparent,
      elevation: AppElevation.none,
      barrierColor: AppColors.modalBarrier,
      builder: (context) => const ExportDataBottomSheet(),
    );
  }

  @override
  State<ExportDataBottomSheet> createState() => _ExportDataBottomSheetState();
}

class _ExportDataBottomSheetState extends State<ExportDataBottomSheet> {
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _isExporting = false;

  Future<void> _exportData(List<Contact> contacts) async {
    if (contacts.isEmpty || _isExporting) {
      return;
    }

    setState(() => _isExporting = true);

    try {
      final exportService = context.read<DataExportService>();
      final sharingService = context.read<SharingService>();

      final exportResult = await ExportDataFileHelper.prepareExportFile(
        contacts: contacts,
        format: _selectedFormat,
        exportService: exportService,
      );

      if (!mounted) return;

      final l10n = context.l10n;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.exportSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await sharingService.shareFile(
        filePath: exportResult.file.path,
        mimeType: exportResult.mimeType,
        subject: exportResult.fileName,
      );
    } on Object catch (e, s) {
      if (mounted) {
        final logger = context.read<Logger?>();
        logger?.e('Failed to export contacts', error: e, stackTrace: s);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final contacts = context.watch<ContactRepository?>()?.contacts ?? [];
    final hasContacts = contacts.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadii.borderSheet,
            boxShadow: [AppColors.shadowSheet(isDark)],
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
                  ExportDataHeader(
                    contactCount: contacts.length,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppDimensions.iconAction),
                  ExportFormatSelector(
                    selectedFormat: _selectedFormat,
                    isEnabled: !_isExporting,
                    onFormatSelected: (format) {
                      setState(() => _selectedFormat = format);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          key: const Key('export_cancel_button'),
                          onPressed: _isExporting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          key: const Key('export_confirm_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: AppSpacing.paddingFieldVertical,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.borderInput,
                            ),
                          ),
                          onPressed: (!hasContacts || _isExporting)
                              ? null
                              : () => _exportData(contacts),
                          icon: _isExporting
                              ? SizedBox(
                                  width: AppDimensions.iconAction,
                                  height: AppDimensions.iconAction,
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        AppDimensions.progressStrokeWidth,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.file_download_outlined,
                                  size: AppDimensions.iconMd,
                                ),
                          label: Text(
                            l10n.exportAction,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary,
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
