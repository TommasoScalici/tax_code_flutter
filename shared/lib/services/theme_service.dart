import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Manages the application's theme state.
///
class ThemeService with ChangeNotifier {
  final SharedPreferencesAsync _prefs;

  ThemeMode _currentTheme = ThemeMode.light;
  ThemeMode get theme => _currentTheme;

  ///
  /// The main constructor for the theme service.
  ///
  ThemeService({required SharedPreferencesAsync prefs}) : _prefs = prefs;

  ///
  /// Toggles the application theme between light and dark mode.
  ///
  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _saveTheme(_currentTheme);
    notifyListeners();
  }

  ///
  /// Loads the saved theme from shared preferences.
  ///
  Future<void> init() async {
    final themeName = await _prefs.getString('theme') ?? 'light';
    _currentTheme =
        ThemeMode.values.where((m) => m.name == themeName).firstOrNull ??
        ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme(ThemeMode theme) async {
    await _prefs.setString('theme', theme.name);
  }
}
