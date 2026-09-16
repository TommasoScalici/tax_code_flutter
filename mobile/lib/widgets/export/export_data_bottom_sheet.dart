import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

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
      elevation: 0,
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
      final exportService = context.read<DataExportServiceAbstract>();
      final sharingService = context.read<SharingServiceAbstract>();

      final dataString = exportService.formatContacts(
        contacts: contacts,
        format: _selectedFormat,
      );

      final ext = exportService.fileExtension(_selectedFormat);
      final mimeType = exportService.mimeType(_selectedFormat);

      final now = DateTime.now();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final fileName = 'codici_fiscali_$timestamp.$ext';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(dataString);

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
        filePath: file.path,
        mimeType: mimeType,
        subject: fileName,
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28.0),
            ),
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
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.40,
                        ),
                        borderRadius: BorderRadius.circular(2.0),
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
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.file_download_outlined,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportDataTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Contact count badge / empty state
                  if (!hasContacts)
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
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
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.exportCodesCount(contacts.length),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // Format selection section
                  Text(
                    l10n.exportFormatLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Format Cards
                  _FormatOptionCard(
                    key: const Key('export_format_json_card'),
                    title: l10n.exportFormatJsonTitle,
                    description: l10n.exportFormatJsonDesc,
                    icon: Icons.data_object_rounded,
                    isSelected: _selectedFormat == ExportFormat.json,
                    onTap: _isExporting
                        ? null
                        : () => setState(
                            () => _selectedFormat = ExportFormat.json,
                          ),
                  ),
                  const SizedBox(height: 10),
                  _FormatOptionCard(
                    key: const Key('export_format_csv_card'),
                    title: l10n.exportFormatCsvTitle,
                    description: l10n.exportFormatCsvDesc,
                    icon: Icons.table_chart_outlined,
                    isSelected: _selectedFormat == ExportFormat.csv,
                    onTap: _isExporting
                        ? null
                        : () => setState(
                            () => _selectedFormat = ExportFormat.csv,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
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
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          key: const Key('export_confirm_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          onPressed: (!hasContacts || _isExporting)
                              ? null
                              : () => _exportData(contacts),
                          icon: _isExporting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.file_download_outlined,
                                  size: 20,
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

class _FormatOptionCard extends StatelessWidget {
  const _FormatOptionCard({
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
