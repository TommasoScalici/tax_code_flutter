import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme constructs Material 3 ThemeData with AppColors.darkColorScheme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme, AppColors.darkColorScheme().toModern());
      expect(theme.scaffoldBackgroundColor, AppColors.darkSurface);
      expect(theme.cardTheme.color, AppColors.darkSurfaceContainer);
      expect(theme.cardTheme.elevation, 0);
    });

    test('lightTheme constructs Material 3 ThemeData with AppColors.lightColorScheme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme, AppColors.lightColorScheme().toModern());
      expect(theme.scaffoldBackgroundColor, AppColors.lightSurface);
      expect(theme.cardTheme.color, AppColors.lightSurfaceContainer);
      expect(theme.cardTheme.elevation, 0);
    });
  });
}
