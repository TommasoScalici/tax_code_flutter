import 'package:material_ui/material_ui.dart';

/// Ergonomic context extensions for accessing theme tokens directly.
extension ThemeContextExtensions on BuildContext {
  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current brightness is [Brightness.dark].
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
