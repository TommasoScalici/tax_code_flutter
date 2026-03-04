import 'package:flutter/material.dart';

final class Settings {
  Settings._();

  static String get mioCodiceFiscaleApiKey => 'miocodicefiscale_access_token';
  static String get googleProviderClientId => 'google_provider_client_id';

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 38, 128, 0),
      brightness: Brightness.light,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 38, 128, 0),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData getLightTheme() => _lightTheme;
  static ThemeData getDarkTheme() => _darkTheme;
}
