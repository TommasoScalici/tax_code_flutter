import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/settings.dart';

void main() {
  group('Settings', () {

    test(
      'getLightTheme returns a ThemeData object with correct light properties',
      () {
        // Act
        final theme = Settings.getLightTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, AppColors.lightPrimary);
      },
    );

    test(
      'getDarkTheme returns a ThemeData object with correct dark properties',
      () {
        // Act
        final theme = Settings.getDarkTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, AppColors.emeraldPrimary);
      },
    );
  });
}
