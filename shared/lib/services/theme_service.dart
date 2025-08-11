import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Manages the application's theme state.
///
class ThemeService with ChangeNotifier {
  final SharedPreferencesAsync _prefs;

  String _currentTheme = 'light';
  String get theme => _currentTheme;

  ///
  /// The main constructor for the theme service.
  ///
  ThemeService({required SharedPreferencesAsync prefs}) : _prefs = prefs;

  ///
  /// Toggles the application theme between light and dark mode.
  ///
  void toggleTheme() {
    _currentTheme = _currentTheme == 'dark' ? 'light' : 'dark';
    _saveTheme(_currentTheme);
    notifyListeners();
  }

  ///
  /// Loads the saved theme from shared preferences.
  ///
  Future<void> init() async {
    _currentTheme = await _prefs.getString('theme') ?? 'light';
    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async {
    await _prefs.setString('theme', theme);
  }
}
