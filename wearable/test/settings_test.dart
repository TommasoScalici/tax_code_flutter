import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';

void main() {
  group('Settings', () {
    test(
      'getWearTheme should return an Emerald Ledger ThemeData calibrated for Wear OS',
      () {
        // Act
        final theme = Settings.getWearTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.visualDensity, VisualDensity.compact);
        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);

        // Verify ColorScheme properties
        expect(theme.colorScheme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, AppColors.emeraldPrimary);
        expect(theme.colorScheme.surface, AppColors.darkSurface);
        expect(theme.colorScheme.surfaceContainer, AppColors.darkSurfaceContainer);

        // Verify CardTheme
        expect(theme.cardTheme.color, AppColors.darkSurfaceContainer);
        expect(theme.cardTheme.elevation, 0);
        final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;
        expect(cardShape.borderRadius, BorderRadius.circular(WearDimensions.cardRadius));

        // Verify FilledButton
        expect(theme.filledButtonTheme.style?.backgroundColor?.resolve({}), AppColors.emeraldPrimary);
      },
    );
  });
}
