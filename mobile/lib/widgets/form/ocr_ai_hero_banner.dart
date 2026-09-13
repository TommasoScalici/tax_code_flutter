import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

/// An attention-grabbing hero card promoting optical OCR / AI scanning
/// of health cards (Tessera Sanitaria) or electronic IDs (CIE) to automatically
/// populate the tax code creation form.
///
/// Styled according to the Stitch design specification with an emerald neon
/// accent border, subtle ambient glow, camera & AI sparkle badge, and pill CTA.
class OcrAiHeroBanner extends StatelessWidget {
  /// Callback triggered when the user taps either the banner or the scan button.
  final VoidCallback onScanPressed;

  /// Optional outer margin around the card container.
  final EdgeInsetsGeometry? margin;

  const OcrAiHeroBanner({
    super.key,
    required this.onScanPressed,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.35 : 0.45,
    );

    final cardBgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    final glowColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.08 : 0.04,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ambient neon glow accent in top-right corner
            Positioned(
              top: -24,
              right: -24,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.09 : 0.06,
                    ),
                  ),
                ),
              ),
            ),

            // Interactive surface
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('ocr_ai_hero_banner_ink_well'),
                onTap: onScanPressed,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Leading Visual: Camera icon with AI sparkle badge
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.16 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? 0.40 : 0.30,
                            ),
                            width: 1.0,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: colorScheme.primary,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text and Action Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title & AI Tag Badge
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.ocrHeroTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: isDark ? 0.20 : 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: isDark ? 0.40 : 0.30,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Subtitle description
                            Text(
                              l10n.ocrHeroSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Pill Action Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: onScanPressed,
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  elevation: 0,
                                ),
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  l10n.ocrHeroButton,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
