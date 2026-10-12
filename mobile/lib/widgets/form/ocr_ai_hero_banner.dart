import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

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
    final l10n = context.l10n;
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
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: borderColor, width: AppDimensions.borderMedium),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderCard,
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
              color: AppColors.transparent,
              child: InkWell(
                key: const Key('ocr_ai_hero_banner_ink_well'),
                onTap: onScanPressed,
                borderRadius: AppRadii.borderCard,
                child: Padding(
                  padding: AppSpacing.paddingCard,
                  child: Row(
                    children: [
                      // Leading Visual: Camera icon with AI sparkle badge
                      Container(
                        width: AppDimensions.avatarMd,
                        height: AppDimensions.avatarMd,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.faint,
                          ),
                          borderRadius: AppRadii.borderInput,
                          border: Border.all(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? AppOpacity.outline : AppOpacity.translucent,
                            ),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              color: colorScheme.primary,
                              size: AppDimensions.iconLg,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: colorScheme.primary,
                                size: AppDimensions.iconXs,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.fieldVertical),

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
                                      letterSpacing: AppLetterSpacing.titleTight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.badgeGap),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.badgeGap,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: isDark ? AppOpacity.glow : AppOpacity.semiTranslucent,
                                    ),
                                    borderRadius: AppRadii.borderBadge,
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: isDark ? AppOpacity.outline : AppOpacity.translucent,
                                      ),
                                      width: AppDimensions.borderThin,
                                    ),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: AppFontSizes.micro,
                                      letterSpacing: AppLetterSpacing.badge,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            // Subtitle description
                            Text(
                              l10n.ocrHeroSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.compact),

                            // Pill Action Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: onScanPressed,
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.fieldVertical,
                                    vertical: AppSpacing.xs,
                                  ),
                                  minimumSize: const Size(0, AppDimensions.iconXl),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.borderPill,
                                  ),
                                  elevation: AppElevation.none,
                                ),
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: AppDimensions.iconSm,
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
