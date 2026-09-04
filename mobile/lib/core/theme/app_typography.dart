import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'test_env.dart';

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
    double fontSize = 22.0,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 2.0,
  }) {
    return _fontJetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.3,
      color: color ?? AppColors.emeraldPrimary,
    );
  }

  /// Compact style for Codice Fiscale inside dashboard cards.
  static TextStyle codeDisplayCard({
    Color? color,
    double fontSize = 17.0,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return _fontJetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 1.6,
      height: 1.2,
      color: color ?? AppColors.emeraldPrimary,
    );
  }

  /// Style for human-readable text beneath optical barcodes.
  static TextStyle barcodeReadableText({Color color = Colors.black}) {
    return _fontJetBrainsMono(
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
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
        fontSize: 36.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.8,
        color: onSurface,
      ),
      displayMedium: _fontInter(
        fontSize: 30.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      displaySmall: _fontInter(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),

      // Headline
      headlineLarge: _fontInter(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      headlineMedium: _fontInter(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      headlineSmall: _fontInter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: onSurface,
      ),

      // Title
      titleLarge: _fontInter(
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: onSurface,
      ),
      titleMedium: _fontInter(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: onSurface,
      ),
      titleSmall: _fontInter(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: onSurfaceVariant,
      ),

      // Body
      bodyLarge: _fontInter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),
      bodyMedium: _fontInter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: onSurface,
      ),
      bodySmall: _fontInter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: onSurfaceVariant,
      ),

      // Label
      labelLarge: _fontInter(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      labelMedium: _fontInter(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: onSurfaceVariant,
      ),
      labelSmall: _fontInter(
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: onSurfaceVariant,
      ),
    );
  }
}
