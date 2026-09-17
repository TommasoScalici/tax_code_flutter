import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';

final class Settings {
  Settings._();

  static ThemeData getLightTheme() => AppTheme.lightTheme;
  static ThemeData getDarkTheme() => AppTheme.darkTheme;
}
