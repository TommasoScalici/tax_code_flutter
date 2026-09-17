import 'package:flutter/material.dart';

/// Ergonomic context extensions for accessing Wear OS theme tokens directly in widgets.
extension ThemeContextExtensions on BuildContext {
  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current brightness is [Brightness.dark].
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Screen size of the wearable display.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width of the wearable display.
  double get screenWidth => screenSize.width;

  /// Screen height of the wearable display.
  double get screenHeight => screenSize.height;
}
