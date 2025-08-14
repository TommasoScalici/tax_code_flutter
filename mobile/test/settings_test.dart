import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/settings.dart';

void main() {
  group('Settings', () {
    group('Configuration Values', () {
      test('mioCodiceFiscaleApiKey returns correct value', () {
        expect(Settings.mioCodiceFiscaleApiKey, 'miocodicefiscale_access_token');
      });

      test('cloudVisionApiKey returns correct value', () {
        expect(Settings.cloudVisionApiKey, 'tax_code_flutter_vision');
      });

      test('projectIdNumber returns correct value', () {
        expect(Settings.projectIdNumber, 'project_id');
      });

      test('googleProviderClientId returns correct value', () {
        expect(Settings.googleProviderClientId, 'google_provider_client_id');
      });
    });
  });

  group('Themes', () {
    const expectedLightPrimaryColor = Color(0xff436833);
    const expectedDarkPrimaryColor = Color(0xffA8D293);

    test('getLightTheme returns a ThemeData with correct light properties', () {
      final theme = Settings.getLightTheme();

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, expectedLightPrimaryColor);
    });

    test('getDarkTheme returns a ThemeData with correct dark properties', () {
      final theme = Settings.getDarkTheme();

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, expectedDarkPrimaryColor);
    });
  });
}