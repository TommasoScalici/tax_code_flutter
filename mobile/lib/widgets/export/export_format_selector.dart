import 'package:material_ui/material_ui.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/export/export_format_option_card.dart';

/// Segmented vertical option selector allowing the user to pick JSON or CSV format.
class ExportFormatSelector extends StatelessWidget {
  /// The currently selected format.
  final ExportFormat selectedFormat;

  /// Callback when a new format is picked.
  final ValueChanged<ExportFormat>? onFormatSelected;

  /// Whether format selection is enabled.
  final bool isEnabled;

  /// Creates an [ExportFormatSelector].
  const ExportFormatSelector({
    required this.selectedFormat,
    this.onFormatSelected,
    this.isEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.exportFormatLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.compact),
        ExportFormatOptionCard(
          key: const Key('export_format_json_card'),
          title: l10n.exportFormatJsonTitle,
          description: l10n.exportFormatJsonDesc,
          icon: Icons.data_object_rounded,
          isSelected: selectedFormat == ExportFormat.json,
          onTap: isEnabled ? () => onFormatSelected?.call(ExportFormat.json) : null,
        ),
        const SizedBox(height: AppSpacing.compact),
        ExportFormatOptionCard(
          key: const Key('export_format_csv_card'),
          title: l10n.exportFormatCsvTitle,
          description: l10n.exportFormatCsvDesc,
          icon: Icons.table_chart_outlined,
          isSelected: selectedFormat == ExportFormat.csv,
          onTap: isEnabled ? () => onFormatSelected?.call(ExportFormat.csv) : null,
        ),
      ],
    );
  }
}
