import 'package:flutter/material.dart';

/// Design tokens for the "Emerald Ledger" theme inspired by Google Stitch.
///
/// Features an OLED-friendly dark mode (pure blacks and charcoal surfaces)
/// accented by vibrant emerald greens, alongside a clean, accessible light mode.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand & Emerald Accents
  // ---------------------------------------------------------------------------
  /// Primary emerald green accent used for CTAs, active states, and highlights.
  static const Color emeraldPrimary = Color(0xFF58C878);

  /// Lighter emerald green for high-visibility accents and glow highlights.
  static const Color emeraldLight = Color(0xFF6EE591);

  /// Deeper emerald shade used for dark mode on-primary contrasts.
  static const Color emeraldDark = Color(0xFF3FA863);

  /// Translucent emerald container tint (16% opacity) for badges and chips.
  static const Color emeraldContainerDark = Color(0x2958C878);

  /// Translucent emerald container tint (20% opacity) for subtle glow effects.
  static const Color emeraldGlow = Color(0x3358C878);

  /// Emerald border accent (25% opacity).
  static const Color emeraldBorder = Color(0x4058C878);

  // ---------------------------------------------------------------------------
  // Dark Palette (OLED-first)
  // ---------------------------------------------------------------------------
  /// Deep black background optimal for OLED energy efficiency and contrast.
  static const Color darkBackground = Color(0xFF121212);

  /// Base dark surface color.
  static const Color darkSurface = Color(0xFF121212);

  /// Deepest surface container for recessed elements in dark mode.
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E0E);

  /// Subtle elevated surface for search bars and secondary containers.
  static const Color darkSurfaceContainerLow = Color(0xFF1C1B1B);

  /// Standard elevated card and bottom-sheet surface.
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);

  /// Higher elevated surface for nested cards and active elements.
  static const Color darkSurfaceContainerHigh = Color(0xFF252525);

  /// Highest surface container for hover/pressed states and dividers.
  static const Color darkSurfaceContainerHighest = Color(0xFF353534);

  /// High-contrast white for primary body text and titles on dark surfaces.
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  /// Soft light-gray for secondary text, labels, and hints.
  static const Color darkOnSurfaceVariant = Color(0xFF9E9E9E);

  /// Border outline for inputs and non-focused containers.
  static const Color darkOutline = Color(0xFF383838);

  /// Low-contrast border outline for subtle card separators.
  static const Color darkOutlineVariant = Color(0xFF2C2C2C);

  /// Error color on dark theme.
  static const Color darkError = Color(0xFFEF5350);

  /// Error container with soft red tint.
  static const Color darkErrorContainer = Color(0x29EF5350);

  /// Text on error container.
  static const Color darkOnError = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Light Palette
  // ---------------------------------------------------------------------------
  /// Off-white background for crisp, high-contrast light mode.
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Base light surface color.
  static const Color lightSurface = Color(0xFFF8FAFC);

  /// Light surface container low.
  static const Color lightSurfaceContainerLow = Color(0xFFF1F5F9);

  /// Pure white elevated card and bottom-sheet surface.
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);

  /// Higher elevated surface for nested elements in light mode.
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E8F0);

  /// Highest surface container for light mode.
  static const Color lightSurfaceContainerHighest = Color(0xFFCBD5E1);

  /// Near-black for primary text in light mode.
  static const Color lightOnSurface = Color(0xFF191B22);

  /// Slate gray for secondary text and hints in light mode.
  static const Color lightOnSurfaceVariant = Color(0xFF64748B);

  /// Border outline in light mode.
  static const Color lightOutline = Color(0xFFCBD5E1);

  /// Subtle border outline in light mode.
  static const Color lightOutlineVariant = Color(0xFFE2E8F0);

  /// Primary green for light mode with accessible contrast ratio.
  static const Color lightPrimary = Color(0xFF008744);

  /// Light mode primary container.
  static const Color lightPrimaryContainer = Color(0xFFD1F2D9);

  /// Text on primary container in light mode.
  static const Color lightOnPrimaryContainer = Color(0xFF005025);

  /// Error color in light mode.
  static const Color lightError = Color(0xFFBA1A1A);

  /// Error container in light mode.
  static const Color lightErrorContainer = Color(0xFFFFDAD6);

  // ---------------------------------------------------------------------------
  // Specialized Utility Colors
  // ---------------------------------------------------------------------------
  /// Pure white background strictly reserved for the optical barcode/QR display.
  /// Guarantees maximum contrast and reliability for hardware laser scanners.
  static const Color opticalWhite = Color(0xFFFFFFFF);

  /// Pure pitch-black strictly reserved for barcode stripes and QR modules.
  static const Color opticalBlack = Color(0xFF000000);

  /// Rating star color.
  static const Color starGold = Color(0xFFFFC107);

  /// Pulse badge color indicating active cloud sync.
  static const Color syncPulse = Color(0xFF58C878);

  // ---------------------------------------------------------------------------
  // Material 3 ColorScheme Builders
  // ---------------------------------------------------------------------------
  /// Constructs the Material 3 [ColorScheme] for the Emerald Ledger dark mode.
  static ColorScheme darkColorScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: emeraldPrimary,
      onPrimary: Color(0xFF000000),
      primaryContainer: emeraldContainerDark,
      onPrimaryContainer: emeraldLight,
      secondary: Color(0xFFC8C6C5),
      onSecondary: Color(0xFF1E1E1E),
      secondaryContainer: Color(0xFF353534),
      onSecondaryContainer: Color(0xFFE5E2E1),
      tertiary: Color(0xFF81C784),
      onTertiary: Color(0xFF003314),
      tertiaryContainer: Color(0xFF1B4332),
      onTertiaryContainer: Color(0xFFA3E9A4),
      error: darkError,
      onError: darkOnError,
      errorContainer: darkErrorContainer,
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceDim: darkSurface,
      surfaceBright: Color(0xFF2C2C2C),
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainerLow: darkSurfaceContainerLow,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE5E2E1),
      onInverseSurface: Color(0xFF1E1E1E),
      inversePrimary: Color(0xFF006D36),
    );
  }

  /// Constructs the Material 3 [ColorScheme] for the Emerald Ledger light mode.
  static ColorScheme lightColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: lightOnPrimaryContainer,
      secondary: Color(0xFF505F76),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD8E2F9),
      onSecondaryContainer: Color(0xFF0E1B2E),
      tertiary: Color(0xFF2E6B47),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFB1F1C5),
      onTertiaryContainer: Color(0xFF00210E),
      error: lightError,
      onError: Color(0xFFFFFFFF),
      errorContainer: lightErrorContainer,
      onErrorContainer: Color(0xFF410002),
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceDim: Color(0xFFE2E8F0),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: lightSurfaceContainerLow,
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHigh: lightSurfaceContainerHigh,
      surfaceContainerHighest: lightSurfaceContainerHighest,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1E1E1E),
      onInverseSurface: Color(0xFFF1F5F9),
      inversePrimary: emeraldLight,
    );
  }
}
