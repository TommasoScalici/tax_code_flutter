import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';

void main() {
  group('Settings', () {
    test(
      'getWearTheme should return a ThemeData object with correct properties',
      () {
        // Arrange
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 38, 128, 0),
          brightness: Brightness.dark,
        );

        // Act
        final theme = Settings.getWearTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.visualDensity, VisualDensity.compact);

        // Verify ColorScheme properties by comparing against a reference
        expect(theme.colorScheme.brightness, expectedColorScheme.brightness);
        expect(theme.colorScheme.primary, expectedColorScheme.primary);
        expect(theme.colorScheme.secondary, expectedColorScheme.secondary);

        // Verify ElevatedButtonTheme properties
        final elevatedButtonBackgroundColor =
            theme.elevatedButtonTheme.style?.backgroundColor;
        expect(elevatedButtonBackgroundColor?.resolve({}), Colors.grey[800]);
      },
    );
  });
}
