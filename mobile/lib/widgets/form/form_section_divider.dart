import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// An elegant horizontal divider with a centered uppercase label,
/// used to visually separate form sections (e.g., between the OCR AI scan
/// banner and the manual input fields).
///
/// Designed in accordance with the Stitch design system using subtle outline
/// lines and tracked typography.
class FormSectionDivider extends StatelessWidget {
  /// Optional custom label. If not provided, defaults to
  /// [AppLocalizations.formOrManualEntry].
  final String? label;

  /// Optional margin around the divider row.
  final EdgeInsetsGeometry? margin;

  const FormSectionDivider({
    super.key,
    this.label,
    this.margin = const EdgeInsets.symmetric(vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final displayText =
        (label ?? l10n.formOrManualEntry).toUpperCase();

    final lineColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.40 : 0.55,
    );

    final textColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.75 : 0.85,
    );

    return Container(
      margin: margin,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: 1.0,
              height: 1.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              displayText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: 1.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
