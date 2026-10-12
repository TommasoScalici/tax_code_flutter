import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_dimensions.dart';

void main() {
  group('AppDimensions', () {
    test('AppSpacing contains expected values and valid EdgeInsets presets', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.badgeGap, 6.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.compact, 10.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.fieldVertical, 14.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.card, 20.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);

      expect(AppSpacing.paddingXxs, const EdgeInsets.all(2.0));
      expect(AppSpacing.paddingXs, const EdgeInsets.all(4.0));
      expect(AppSpacing.paddingSm, const EdgeInsets.all(8.0));
      expect(AppSpacing.paddingMd, const EdgeInsets.all(12.0));
      expect(AppSpacing.paddingLg, const EdgeInsets.all(16.0));
      expect(AppSpacing.paddingCard, const EdgeInsets.all(20.0));
      expect(AppSpacing.paddingXl, const EdgeInsets.all(24.0));
      expect(AppSpacing.paddingXxl, const EdgeInsets.all(32.0));
      expect(AppSpacing.screenMargin, const EdgeInsets.symmetric(horizontal: 16.0));
      expect(AppSpacing.paddingField, const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0));
      expect(AppSpacing.paddingFieldVertical, const EdgeInsets.symmetric(vertical: 14.0));
      expect(AppSpacing.labelPadding, const EdgeInsets.only(left: 4.0, bottom: 6.0));
      expect(AppSpacing.errorPadding, const EdgeInsets.only(left: 8.0, top: 6.0));
      expect(AppSpacing.paddingStickyBar, const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0));
    });

    test('AppRadii contains expected values and valid BorderRadius presets', () {
      expect(AppRadii.handle, 2.0);
      expect(AppRadii.badge, 6.0);
      expect(AppRadii.sm, 8.0);
      expect(AppRadii.compact, 10.0);
      expect(AppRadii.inner, 12.0);
      expect(AppRadii.input, 14.0);
      expect(AppRadii.md, 16.0);
      expect(AppRadii.card, 20.0);
      expect(AppRadii.dialog, 24.0);
      expect(AppRadii.pill, 999.0);

      expect(AppRadii.borderHandle, BorderRadius.circular(2.0));
      expect(AppRadii.borderBadge, BorderRadius.circular(6.0));
      expect(AppRadii.borderSm, BorderRadius.circular(8.0));
      expect(AppRadii.borderCompact, BorderRadius.circular(10.0));
      expect(AppRadii.borderInner, BorderRadius.circular(12.0));
      expect(AppRadii.borderInput, BorderRadius.circular(14.0));
      expect(AppRadii.borderMd, BorderRadius.circular(16.0));
      expect(AppRadii.borderCard, BorderRadius.circular(20.0));
      expect(AppRadii.borderDialog, BorderRadius.circular(24.0));
      expect(AppRadii.borderPill, BorderRadius.circular(999.0));
    });

    test('AppOpacity contains expected values', () {
      expect(AppOpacity.tint, 0.08);
      expect(AppOpacity.faint, 0.12);
      expect(AppOpacity.semiTranslucent, 0.16);
      expect(AppOpacity.glow, 0.20);
      expect(AppOpacity.subtleBorder, 0.25);
      expect(AppOpacity.translucent, 0.30);
      expect(AppOpacity.disabled, 0.38);
      expect(AppOpacity.outline, 0.40);
      expect(AppOpacity.divider, 0.50);
      expect(AppOpacity.subtle, 0.55);
      expect(AppOpacity.muted, 0.60);
      expect(AppOpacity.medium, 0.70);
      expect(AppOpacity.prominent, 0.75);
      expect(AppOpacity.high, 0.85);
      expect(AppOpacity.almostOpaque, 0.95);
      expect(AppOpacity.surfaceBlur, 0.95);
    });

    test('AppDimensions contains accessibility standards and icon sizes', () {
      expect(AppDimensions.borderHairline, 0.5);
      expect(AppDimensions.borderThin, 0.8);
      expect(AppDimensions.borderDefault, 1.0);
      expect(AppDimensions.borderMedium, 1.2);
      expect(AppDimensions.borderThick, 1.5);
      expect(AppDimensions.borderSelected, 2.0);
      expect(AppDimensions.progressStrokeWidth, 2.5);
      expect(AppDimensions.dragHandleWidth, 32.0);
      expect(AppDimensions.dragHandleHeight, 4.0);
      expect(AppDimensions.avatarSm, 38.0);
      expect(AppDimensions.avatarMd, 48.0);
      expect(AppDimensions.avatarLg, 58.0);
      expect(AppDimensions.searchBarHeight, 50.0);
      expect(AppDimensions.primaryButtonHeight, 52.0);
      expect(AppDimensions.heroButtonHeight, 56.0);
      expect(AppDimensions.minTouchTarget, 48.0);
      expect(AppDimensions.iconXs, 14.0);
      expect(AppDimensions.iconSm, 16.0);
      expect(AppDimensions.iconAction, 18.0);
      expect(AppDimensions.iconMd, 20.0);
      expect(AppDimensions.iconButton, 22.0);
      expect(AppDimensions.iconLg, 24.0);
      expect(AppDimensions.iconXl, 32.0);
      expect(AppDimensions.iconDisplay, 40.0);
      expect(AppDimensions.iconHero, 48.0);
      expect(AppDimensions.avatarHeader, 34.0);
      expect(AppDimensions.avatarBadge, 36.0);
      expect(AppDimensions.avatarBrand, 54.0);
      expect(AppDimensions.iconIllustrationContainer, 88.0);
      expect(AppDimensions.buttonHeightCompact, 44.0);
      expect(AppDimensions.segmentedHeight, 42.0);
      expect(AppDimensions.maxContentWidth, 520.0);
      expect(AppDimensions.maxDashboardWidth, 600.0);
      expect(AppDimensions.maxWelcomeWidth, 480.0);
      expect(AppDimensions.maxEmptyStateWidth, 420.0);
      expect(AppDimensions.maxDropdownWidth, 360.0);
      expect(AppDimensions.maxSubtitleWidth, 320.0);
    });

    test('AppFontSizes contains consistent typographic scale values', () {
      expect(AppFontSizes.micro, 10.0);
      expect(AppFontSizes.caption, 11.0);
      expect(AppFontSizes.bodySm, 12.0);
      expect(AppFontSizes.titleSm, 13.0);
      expect(AppFontSizes.bodyMd, 14.0);
      expect(AppFontSizes.input, 15.0);
      expect(AppFontSizes.bodyLg, 16.0);
      expect(AppFontSizes.headlineSm, 18.0);
      expect(AppFontSizes.headlineMd, 20.0);
    });
  });
}
