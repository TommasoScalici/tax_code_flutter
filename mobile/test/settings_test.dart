import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/settings.dart';

void main() {
  group('Settings', () {
    const seedColor = Color.fromARGB(255, 38, 128, 0);

    test('API key getters return correct constant values', () {
      // Act & Assert
      expect(Settings.mioCodiceFiscaleApiKey, 'miocodicefiscale_access_token');
      expect(Settings.googleProviderClientId, 'google_provider_client_id');
    });

    test(
      'getLightTheme returns a ThemeData object with correct light properties',
      () {
        // Arrange
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        );

        // Act
        final theme = Settings.getLightTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, expectedColorScheme.primary);
      },
    );

    test(
      'getDarkTheme returns a ThemeData object with correct dark properties',
      () {
        // Arrange
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        );

        // Act
        final theme = Settings.getDarkTheme();

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, expectedColorScheme.primary);
      },
    );
  });
}
