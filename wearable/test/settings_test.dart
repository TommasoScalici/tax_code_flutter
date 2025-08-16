import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';

void main() {
  group('Settings', () {
    test('getWearTheme should return a valid dark theme', () {
      // Act
      final theme = Settings.getWearTheme();

      // Assert
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark, reason: 'Wear OS themes should be dark by default');
    });
  });
}