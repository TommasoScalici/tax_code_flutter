import 'package:flutter/widgets.dart';

/// Layout tokens, insets, and dimension constants calibrated for Wear OS smartwatch displays.
///
/// Ensures safe margins on circular and square watch faces, preventing content clipping
/// on curved edges and providing comfortable touch targets.
abstract final class WearDimensions {
  // ---------------------------------------------------------------------------
  // Screen & Scroll Padding (Circular Safe Insets)
  // ---------------------------------------------------------------------------
  /// Horizontal padding for watch screens.
  static const double screenPaddingHorizontal = 12.0;

  /// Top padding for scrollable lists, leaving room for the system clock header.
  static const double screenPaddingTop = 22.0;

  /// Generous bottom padding allowing the last card to scroll comfortably to the screen center.
  static const double screenPaddingBottom = 44.0;

  /// EdgeInsets for main watch scroll views on round screens.
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(
    screenPaddingHorizontal,
    screenPaddingTop,
    screenPaddingHorizontal,
    screenPaddingBottom,
  );

  // ---------------------------------------------------------------------------
  // Corner Radii
  // ---------------------------------------------------------------------------
  /// Corner radius for compact contact cards.
  static const double cardRadius = 18.0;

  /// Corner radius for Codice Fiscale monospace badge pills.
  static const double pillRadius = 8.0;

  /// Stadium border radius for buttons and toggle chips.
  static const double stadiumRadius = 999.0;

  /// Corner radius for the optical white barcode/QR presentation container.
  static const double opticalRadius = 16.0;

  /// Corner radius for dialogs and modal confirmation sheets.
  static const double dialogRadius = 24.0;

  // ---------------------------------------------------------------------------
  // Card & Container Sizing
  // ---------------------------------------------------------------------------
  /// Internal padding for contact cards.
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 10.0,
    vertical: 8.0,
  );

  /// Vertical margin between cards in the list.
  static const double cardSpacing = 6.0;

  /// Internal padding for the Codice Fiscale pill inside the card.
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(
    horizontal: 8.0,
    vertical: 2.5,
  );

  /// Padding inside the high-contrast optical white container.
  static const EdgeInsets opticalPadding = EdgeInsets.all(12.0);

  // ---------------------------------------------------------------------------
  // Interactive Elements & Touch Targets
  // ---------------------------------------------------------------------------
  /// Minimum height for primary buttons on Wear OS.
  static const double buttonHeight = 40.0;

  /// Compact height for secondary/pill buttons.
  static const double buttonCompactHeight = 34.0;

  /// Standard small icon size (e.g. status hints, clock icon).
  static const double iconSmall = 14.0;

  /// Standard medium icon size (e.g. card icons, actions).
  static const double iconMedium = 18.0;

  /// Large icon size for empty states and hero badges.
  static const double iconLarge = 32.0;
}
