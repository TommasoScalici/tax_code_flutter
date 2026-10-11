import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_dimensions.dart';

void main() {
  group('AppDimensions', () {
    test('AppSpacing contains expected values and valid EdgeInsets presets', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);

      expect(AppSpacing.paddingXs, const EdgeInsets.all(4.0));
      expect(AppSpacing.paddingSm, const EdgeInsets.all(8.0));
      expect(AppSpacing.paddingMd, const EdgeInsets.all(12.0));
      expect(AppSpacing.paddingLg, const EdgeInsets.all(16.0));
      expect(AppSpacing.paddingXl, const EdgeInsets.all(24.0));
      expect(AppSpacing.paddingXxl, const EdgeInsets.all(32.0));
      expect(AppSpacing.screenMargin, const EdgeInsets.symmetric(horizontal: 16.0));
    });

    test('AppRadii contains expected values and valid BorderRadius presets', () {
      expect(AppRadii.sm, 8.0);
      expect(AppRadii.md, 16.0);
      expect(AppRadii.card, 20.0);
      expect(AppRadii.dialog, 24.0);
      expect(AppRadii.pill, 999.0);

      expect(AppRadii.borderSm, BorderRadius.circular(8.0));
      expect(AppRadii.borderMd, BorderRadius.circular(16.0));
      expect(AppRadii.borderCard, BorderRadius.circular(20.0));
      expect(AppRadii.borderDialog, BorderRadius.circular(24.0));
      expect(AppRadii.borderPill, BorderRadius.circular(999.0));
    });

    test('AppOpacity contains expected values', () {
      expect(AppOpacity.disabled, 0.38);
      expect(AppOpacity.subtle, 0.55);
      expect(AppOpacity.medium, 0.70);
      expect(AppOpacity.high, 0.85);
    });

    test('AppDimensions contains accessibility standards and icon sizes', () {
      expect(AppDimensions.minTouchTarget, 48.0);
      expect(AppDimensions.iconSm, 16.0);
      expect(AppDimensions.iconMd, 20.0);
      expect(AppDimensions.iconLg, 24.0);
      expect(AppDimensions.iconXl, 32.0);
    });
  });
}
