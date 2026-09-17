import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';

/// Typography definitions calibrated for compact Wear OS smartwatch displays (1.2"–1.4").
///
/// Features high-contrast letterforms with clear distinction between text levels,
/// robust monospace styling for Codice Fiscale, and zero reliance on dynamic network fonts.
abstract final class WearTypography {
  // ---------------------------------------------------------------------------
  // Monospace Codice Fiscale & Machine Data
  // ---------------------------------------------------------------------------

  /// Compact monospace style for Codice Fiscale inside list cards.
  static TextStyle codeDisplayCard({
    Color? color,
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.2,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier', 'monospace'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.15,
      color: color ?? AppColors.emeraldLight,
    );
  }

  /// Enlarged monospace style for Codice Fiscale in presentation screen.
  static TextStyle codeDisplayPresentation({
    Color? color,
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.4,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier', 'monospace'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.2,
      color: color ?? AppColors.opticalTextPrimary,
    );
  }

  /// Small optical barcode label beneath 1D barcodes.
  static TextStyle barcodeReadableText({
    Color color = AppColors.opticalTextPrimary,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier', 'monospace'],
      fontSize: 10.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Specialized Wear Elements
  // ---------------------------------------------------------------------------

  /// Style for the system clock header at the top of the watch face.
  static TextStyle clockHeader({Color? color}) {
    return TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: color ?? AppColors.darkOnSurface,
    );
  }

  /// Contact name in list cards.
  static TextStyle cardTitle({Color? color}) {
    return TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      height: 1.2,
      color: color ?? AppColors.darkOnSurface,
    );
  }

  /// Birthplace, birth date, and secondary metadata in cards.
  static TextStyle cardSubtitle({Color? color}) {
    return TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: color ?? AppColors.darkOnSurfaceVariant,
    );
  }

  /// Micro-status and helper hints (e.g. "Swipe to close").
  static TextStyle hint({Color? color}) {
    return TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: color ?? AppColors.darkOnSurfaceVariant,
    );
  }

  // ---------------------------------------------------------------------------
  // Material 3 TextTheme Builder for Wear OS
  // ---------------------------------------------------------------------------

  /// Creates a compact Material 3 [TextTheme] tuned for high readability on dark OLED watch faces.
  static TextTheme createTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      // Headlines / Titles
      headlineMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),

      // Body text
      bodyMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w400,
        height: 1.25,
        color: onSurfaceVariant,
      ),

      // Buttons / Labels
      labelLarge: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: onSurfaceVariant,
      ),
    );
  }
}
