import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/test_env.dart';

/// Typography definitions for the "Emerald Ledger" design system.
///
/// Standard UI elements use [GoogleFonts.inter] for maximum clarity.
/// Fiscal codes (Codice Fiscale) and machine-readable data use [GoogleFonts.jetBrainsMono]
/// to ensure unambiguous character differentiation (e.g., distinguishing '0' from 'O').
abstract final class AppTypography {
  static bool get _isTest => isFlutterTestEnvironment;

  static TextStyle _fontInter({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    if (_isTest) {
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _fontJetBrainsMono({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    if (_isTest) {
      return TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // JetBrains Mono — Codice Fiscale & Optical Machine Data
  // ---------------------------------------------------------------------------

  /// Style for displaying full-size Codice Fiscale (e.g. in details, barcode sheet).
  static TextStyle codeDisplay({
    Color? color,
    double fontSize = AppFontSizes.codeDisplay,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = AppLetterSpacing.codeDisplay,
  }) {
    return _fontJetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: AppLineHeights.code,
      color: color,
    );
  }

  /// Compact style for Codice Fiscale inside dashboard cards.
  static TextStyle codeDisplayCard({
    Color? color,
    double fontSize = AppFontSizes.cardTitle,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return _fontJetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: AppLetterSpacing.codeCard,
      height: AppLineHeights.heading,
      color: color,
    );
  }

  /// Style for human-readable text beneath optical barcodes.
  static TextStyle barcodeReadableText({Color color = AppColors.opticalBlack}) {
    return _fontJetBrainsMono(
      fontSize: AppFontSizes.titleSm,
      fontWeight: FontWeight.w700,
      letterSpacing: AppLetterSpacing.barcode,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Inter — General UI Text Themes
  // ---------------------------------------------------------------------------

  /// Generates the [TextTheme] based on Inter, tuned for dark or light surfaces.
  static TextTheme createTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      // Display
      displayLarge: _fontInter(
        fontSize: AppFontSizes.displayLg,
        fontWeight: FontWeight.w700,
        height: AppLineHeights.heading,
        letterSpacing: AppLetterSpacing.displayLg,
        color: onSurface,
      ),
      displayMedium: _fontInter(
        fontSize: AppFontSizes.displayMd,
        fontWeight: FontWeight.w700,
        height: AppLineHeights.displayCode,
        letterSpacing: AppLetterSpacing.headlineTight,
        color: onSurface,
      ),
      displaySmall: _fontInter(
        fontSize: AppFontSizes.headlineLg,
        fontWeight: FontWeight.w700,
        height: AppLineHeights.code,
        color: onSurface,
      ),

      // Headline
      headlineLarge: _fontInter(
        fontSize: AppFontSizes.headlineLg,
        fontWeight: FontWeight.w700,
        height: AppLineHeights.code,
        color: onSurface,
      ),
      headlineMedium: _fontInter(
        fontSize: AppFontSizes.headlineMd,
        fontWeight: FontWeight.w600,
        height: AppLineHeights.headingMd,
        letterSpacing: AppLetterSpacing.titleTight,
        color: onSurface,
      ),
      headlineSmall: _fontInter(
        fontSize: AppFontSizes.headlineSm,
        fontWeight: FontWeight.w600,
        height: AppLineHeights.body,
        color: onSurface,
      ),

      // Title
      titleLarge: _fontInter(
        fontSize: AppFontSizes.cardTitle,
        fontWeight: FontWeight.w600,
        height: AppLineHeights.body,
        color: onSurface,
      ),
      titleMedium: _fontInter(
        fontSize: AppFontSizes.input,
        fontWeight: FontWeight.w600,
        height: AppLineHeights.body,
        color: onSurface,
      ),
      titleSmall: _fontInter(
        fontSize: AppFontSizes.titleSm,
        fontWeight: FontWeight.w600,
        height: AppLineHeights.body,
        color: onSurfaceVariant,
      ),

      // Body
      bodyLarge: _fontInter(
        fontSize: AppFontSizes.bodyLg,
        fontWeight: FontWeight.w400,
        height: AppLineHeights.comfortable,
        color: onSurface,
      ),
      bodyMedium: _fontInter(
        fontSize: AppFontSizes.bodyMd,
        fontWeight: FontWeight.w400,
        height: AppLineHeights.relaxed,
        color: onSurface,
      ),
      bodySmall: _fontInter(
        fontSize: AppFontSizes.bodySm,
        fontWeight: FontWeight.w400,
        height: AppLineHeights.body,
        color: onSurfaceVariant,
      ),

      // Label
      labelLarge: _fontInter(
        fontSize: AppFontSizes.bodyMd,
        fontWeight: FontWeight.w600,
        letterSpacing: AppLetterSpacing.subtle,
        color: onSurface,
      ),
      labelMedium: _fontInter(
        fontSize: AppFontSizes.bodySm,
        fontWeight: FontWeight.w600,
        letterSpacing: AppLetterSpacing.label,
        color: onSurfaceVariant,
      ),
      labelSmall: _fontInter(
        fontSize: AppFontSizes.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: AppLetterSpacing.caption,
        color: onSurfaceVariant,
      ),
    );
  }
}
