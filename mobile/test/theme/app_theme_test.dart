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
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadii.borderCard,
      );

      // AppBar
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.appBarTheme.surfaceTintColor, AppColors.transparent);

      // FAB OLED elevation
      expect(theme.floatingActionButtonTheme.elevation, 0);

      // BottomSheet & Dialog
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      expect(theme.bottomSheetTheme.elevation, 16);
      expect(theme.dialogTheme.elevation, 8);
      expect(
        (theme.dialogTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadii.borderDialog,
      );

      // Input Decoration
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.contentPadding, AppSpacing.paddingField);

      // Divider
      expect(theme.dividerTheme.thickness, 1);
      expect(theme.dividerTheme.space, 1);
    });

    test('lightTheme constructs Material 3 ThemeData with AppColors.lightColorScheme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme, AppColors.lightColorScheme().toModern());
      expect(theme.scaffoldBackgroundColor, AppColors.lightSurface);
      expect(theme.cardTheme.color, AppColors.lightSurfaceContainer);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadii.borderCard,
      );

      // AppBar
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.appBarTheme.surfaceTintColor, AppColors.transparent);

      // FAB light elevation
      expect(theme.floatingActionButtonTheme.elevation, 2);

      // BottomSheet & Dialog
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      expect(theme.bottomSheetTheme.elevation, 16);
      expect(theme.dialogTheme.elevation, 8);
      expect(
        (theme.dialogTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadii.borderDialog,
      );

      // Input Decoration
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.contentPadding, AppSpacing.paddingField);

      // Divider
      expect(theme.dividerTheme.thickness, 1);
      expect(theme.dividerTheme.space, 1);
    });
  });
}
