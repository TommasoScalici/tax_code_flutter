import 'package:flutter/material.dart';

class Settings {
  static ThemeData getWearTheme() {
    return ThemeData(
      visualDensity: VisualDensity.compact,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 38, 128, 0),
        brightness: Brightness.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
      ),
    );
  }
}