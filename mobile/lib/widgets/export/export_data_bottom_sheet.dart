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
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
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
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadii.borderSheet,
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
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: AppDimensions.dragHandleWidth,
                      height: AppDimensions.dragHandleHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: AppOpacity.outline,
                        ),
                        borderRadius: AppRadii.borderHandle,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.compact),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.file_download_outlined,
                          color: theme.colorScheme.primary,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.fieldVertical),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportDataTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: AppLetterSpacing.titleTight,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
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
                  const SizedBox(height: AppDimensions.iconAction),

                  // Contact count badge / empty state
                  if (!hasContacts)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.fieldVertical),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: AppOpacity.translucent,
                        ),
                        borderRadius: AppRadii.borderInput,
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: AppOpacity.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.error,
                            size: AppDimensions.iconMd,
                          ),
                          const SizedBox(width: AppSpacing.md),
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
                        horizontal: AppSpacing.fieldVertical,
                        vertical: AppSpacing.compact,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: AppRadii.borderInput,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: AppDimensions.iconAction,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.compact),
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
                  const SizedBox(height: AppDimensions.iconAction),

                  // Format selection section
                  Text(
                    l10n.exportFormatLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.compact),

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
                  const SizedBox(height: AppSpacing.compact),
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
                  const SizedBox(height: AppSpacing.xl),

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
                                    strokeWidth: AppDimensions.progressStrokeWidth,
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
            alpha: isDark ? AppOpacity.faint : AppOpacity.tint,
          )
        : theme.colorScheme.surfaceContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingField,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.borderMd,
          border: Border.all(
            color: borderColor,
            width: isSelected ? AppDimensions.borderSelected : AppDimensions.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(
                        alpha: isDark ? AppOpacity.glow : AppOpacity.faint,
                      )
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppRadii.borderCompact,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconButton,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.fieldVertical),
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
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
