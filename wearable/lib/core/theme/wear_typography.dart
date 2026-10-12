import 'package:flutter/material.dart';
import 'package:shared/theme/app_dimensions.dart';
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
    double fontSize = AppFontSizes.caption,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = AppLetterSpacing.caption,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier', 'monospace'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: AppLineHeights.headerCompact,
      color: color ?? AppColors.emeraldLight,
    );
  }

  /// Enlarged monospace style for Codice Fiscale in presentation screen.
  static TextStyle codeDisplayPresentation({
    Color? color,
    double fontSize = AppFontSizes.input,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = AppLetterSpacing.wide,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier', 'monospace'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: AppLineHeights.heading,
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
      fontSize: AppFontSizes.micro,
      fontWeight: FontWeight.w700,
      letterSpacing: AppLetterSpacing.wide,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Specialized Wear Elements
  // ---------------------------------------------------------------------------

  /// Style for the system clock header at the top of the watch face.
  static TextStyle clockHeader({Color? color}) {
    return TextStyle(
      fontSize: AppFontSizes.watchTitleMd,
      fontWeight: FontWeight.w600,
      letterSpacing: AppLetterSpacing.label,
      color: color ?? AppColors.darkOnSurface,
    );
  }

  /// Contact name in list cards.
  static TextStyle cardTitle({Color? color}) {
    return TextStyle(
      fontSize: AppFontSizes.watchTitleMd,
      fontWeight: FontWeight.w700,
      letterSpacing: AppLetterSpacing.snug,
      height: AppLineHeights.heading,
      color: color ?? AppColors.darkOnSurface,
    );
  }

  /// Birthplace, birth date, and secondary metadata in cards.
  static TextStyle cardSubtitle({Color? color}) {
    return TextStyle(
      fontSize: AppFontSizes.micro,
      fontWeight: FontWeight.w500,
      height: AppLineHeights.heading,
      color: color ?? AppColors.darkOnSurfaceVariant,
    );
  }

  /// Micro-status and helper hints (e.g. "Swipe to close").
  static TextStyle hint({Color? color}) {
    return TextStyle(
      fontSize: AppFontSizes.watchMicro,
      fontWeight: FontWeight.w500,
      letterSpacing: AppLetterSpacing.subtle,
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
        fontSize: AppFontSizes.bodyLg,
        fontWeight: FontWeight.w700,
        letterSpacing: AppLetterSpacing.titleTight,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: AppFontSizes.bodyMd,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: AppFontSizes.titleSm,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: AppFontSizes.watchTitleSm,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),

      // Body text
      bodyMedium: TextStyle(
        fontSize: AppFontSizes.bodySm,
        fontWeight: FontWeight.w400,
        height: AppLineHeights.code,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: AppFontSizes.watchCaption,
        fontWeight: FontWeight.w400,
        height: AppLineHeights.displayCode,
        color: onSurfaceVariant,
      ),

      // Buttons / Labels
      labelLarge: TextStyle(
        fontSize: AppFontSizes.watchTitleMd,
        fontWeight: FontWeight.w700,
        letterSpacing: AppLetterSpacing.subtle,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: AppFontSizes.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: AppLetterSpacing.subtle,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: AppFontSizes.watchMicro,
        fontWeight: FontWeight.w600,
        letterSpacing: AppLetterSpacing.tracked,
        color: onSurfaceVariant,
      ),
    );
  }
}
