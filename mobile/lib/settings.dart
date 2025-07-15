import 'package:flutter/material.dart';

final class Settings {
  static String get mioCodiceFiscaleApiKey => 'miocodicefiscale_access_token';
  static String get cloudVisionApiKey => 'tax_code_flutter_vision';
  static String get projectIdNumber => 'project_id';
  static String get googleProviderClientId => 'google_provider_client_id';

  static ThemeData getLightTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0),
            brightness: Brightness.light));
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0),
            brightness: Brightness.dark));
  }
}
