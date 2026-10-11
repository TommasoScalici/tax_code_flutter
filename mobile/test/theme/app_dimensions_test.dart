import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

void main() {
  group('Mobile AppDimensions', () {
    test('exports AppSpacing, AppRadii, AppOpacity and AppDimensions correctly', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);

      expect(AppRadii.sm, 8.0);
      expect(AppRadii.md, 16.0);
      expect(AppRadii.card, 20.0);
      expect(AppRadii.dialog, 24.0);
      expect(AppRadii.pill, 999.0);

      expect(AppOpacity.disabled, 0.38);
      expect(AppOpacity.subtle, 0.55);
      expect(AppOpacity.medium, 0.70);
      expect(AppOpacity.high, 0.85);

      expect(AppDimensions.minTouchTarget, 48.0);
    });
  });
}
