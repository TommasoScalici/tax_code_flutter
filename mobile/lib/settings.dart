import 'package:material_ui/material_ui.dart';
import 'core/theme/app_theme.dart';

final class Settings {
  Settings._();

  static String get googleProviderClientId => 'google_provider_client_id';

  static ThemeData getLightTheme() => AppTheme.lightTheme;
  static ThemeData getDarkTheme() => AppTheme.darkTheme;
}
