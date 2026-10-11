import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

void main() {
  group('Mobile AppDimensions', () {
    test('exports AppSpacing, AppRadii, AppOpacity and AppDimensions correctly', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.card, 20.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);

      expect(AppRadii.handle, 2.0);
      expect(AppRadii.sm, 8.0);
      expect(AppRadii.compact, 10.0);
      expect(AppRadii.inner, 12.0);
      expect(AppRadii.input, 14.0);
      expect(AppRadii.md, 16.0);
      expect(AppRadii.card, 20.0);
      expect(AppRadii.dialog, 24.0);
      expect(AppRadii.pill, 999.0);

      expect(AppOpacity.faint, 0.12);
      expect(AppOpacity.glow, 0.20);
      expect(AppOpacity.disabled, 0.38);
      expect(AppOpacity.outline, 0.40);
      expect(AppOpacity.divider, 0.50);
      expect(AppOpacity.subtle, 0.55);
      expect(AppOpacity.muted, 0.60);
      expect(AppOpacity.medium, 0.70);
      expect(AppOpacity.prominent, 0.75);
      expect(AppOpacity.high, 0.85);
      expect(AppOpacity.surfaceBlur, 0.95);

      expect(AppDimensions.dragHandleWidth, 32.0);
      expect(AppDimensions.dragHandleHeight, 4.0);
      expect(AppDimensions.avatarSm, 38.0);
      expect(AppDimensions.avatarMd, 48.0);
      expect(AppDimensions.avatarLg, 58.0);
      expect(AppDimensions.searchBarHeight, 50.0);
      expect(AppDimensions.primaryButtonHeight, 52.0);
      expect(AppDimensions.minTouchTarget, 48.0);
      expect(AppDimensions.iconXs, 14.0);
      expect(AppDimensions.iconSm, 16.0);
      expect(AppDimensions.iconMd, 20.0);
      expect(AppDimensions.iconLg, 24.0);
      expect(AppDimensions.iconXl, 32.0);
    });
  });
}
