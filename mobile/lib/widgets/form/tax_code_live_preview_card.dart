import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

/// A card that dynamically previews the calculated Italian Tax Code (Codice Fiscale)
/// in real time as the user fills out the form.
///
/// Features JetBrains Mono monospaced typography, emerald glow when complete,
/// and tap-to-copy feedback.
class TaxCodeLivePreviewCard extends StatelessWidget {
  /// The currently calculated tax code, or null/empty if incomplete.
  final String? taxCode;

  /// Optional margin around the preview card.
  final EdgeInsetsGeometry? margin;

  /// Optional callback invoked after the code is successfully copied to clipboard.
  final VoidCallback? onCopied;

  const TaxCodeLivePreviewCard({
    super.key,
    required this.taxCode,
    this.margin,
    this.onCopied,
  });

  bool get _isComplete => taxCode != null && taxCode!.trim().length == 16;

  Future<void> _copyCode(BuildContext context, String code, AppLocalizations? l10n) async {
    onCopied?.call();

    try {
      await Clipboard.setData(ClipboardData(text: code));
      await HapticFeedback.lightImpact();
    } on Object catch (_) {
      // Ignored in test / headless environments
    }

    if (context.mounted && l10n != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taxCodeCopied),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedTitle = l10n?.taxCodeLivePreviewTitle ?? 'Codice Calcolato in Anteprima';
    final resolvedHint = l10n?.taxCodeLivePreviewHint ?? 'Compila tutti i campi per il calcolo automatico';

    final effectiveCode = (taxCode != null && taxCode!.isNotEmpty) ? taxCode!.toUpperCase() : null;

    final borderColor = _isComplete
        ? colorScheme.primary.withValues(alpha: isDark ? 0.45 : 0.6)
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.7);

    final bgColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: _isComplete
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: const Key('tax_code_live_preview_inkwell'),
          onTap: _isComplete ? () => _copyCode(context, effectiveCode!, l10n) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Leading verified / calculation icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isComplete
                        ? colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.12)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isComplete ? Icons.verified_rounded : Icons.pending_rounded,
                    color: _isComplete ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resolvedTitle.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (effectiveCode != null)
                        Text(
                          effectiveCode,
                          style: AppTypography.codeDisplayCard(
                            color: _isComplete ? colorScheme.primary : colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        )
                      else
                        Text(
                          resolvedHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Copy Action Indicator
                if (_isComplete)
                  IconButton(
                    key: const Key('tax_code_live_preview_copy_button'),
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    tooltip: l10n?.copyTaxCode,
                    onPressed: () => _copyCode(context, effectiveCode!, l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
