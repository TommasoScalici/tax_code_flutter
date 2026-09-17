import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_theme.dart';

/// Application-wide settings and theme providers for Wear OS.
final class Settings {
  Settings._();

  /// Returns the Material 3 "Emerald Ledger" theme optimized for Wear OS.
  static ThemeData getWearTheme() => WearTheme.darkTheme;
}