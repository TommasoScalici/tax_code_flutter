import 'package:flutter/widgets.dart';
import 'package:shared/theme/app_dimensions.dart';

/// Layout tokens, insets, and dimension constants calibrated for Wear OS smartwatch displays.
///
/// Ensures safe margins on circular and square watch faces, preventing content clipping
/// on curved edges and providing comfortable touch targets.
abstract final class WearDimensions {
  // ---------------------------------------------------------------------------
  // Screen & Scroll Padding (Circular Safe Insets)
  // ---------------------------------------------------------------------------
  /// Horizontal padding for watch screens.
  static const double screenPaddingHorizontal = AppSpacing.fieldVertical;

  /// Top padding for scrollable lists, leaving safe clearance for circular bezels and clock header.
  static const double screenPaddingTop = AppRadii.sheet;

  /// Generous bottom padding allowing the last card or element to scroll comfortably into the safe center area.
  static const double screenPaddingBottom = AppDimensions.primaryButtonHeight;

  /// EdgeInsets for main watch scroll views on round screens.
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(
    screenPaddingHorizontal,
    screenPaddingTop,
    screenPaddingHorizontal,
    screenPaddingBottom,
  );

  /// Clock header padding at the top of Wear OS screens.
  static const EdgeInsets headerClockPadding = EdgeInsets.only(
    top: AppSpacing.xxs,
    bottom: AppSpacing.xs,
  );

  // ---------------------------------------------------------------------------
  // Scrollbar Tokens
  // ---------------------------------------------------------------------------
  /// Standard curved scrollbar stroke thickness: 4.0 pt.
  static const double scrollbarThickness = AppSpacing.xs;

  /// Distance between scrollbar and display edge: 3.0 pt.
  static const double scrollbarMargin = AppSpacing.badgeVertical;

  /// Total angular span of the track arc in degrees: 72.0 deg.
  static const double scrollbarArcDegrees = 72.0;

  /// Default opacity for the curved scrollbar track: 22%.
  static const double scrollbarTrackAlpha = 0.22;

  // ---------------------------------------------------------------------------
  // Corner Radii
  // ---------------------------------------------------------------------------
  /// Corner radius for compact contact cards.
  static const double cardRadius = 18.0;

  /// Corner radius for Codice Fiscale monospace badge pills.
  static const double pillRadius = AppRadii.sm;

  /// Stadium border radius for buttons and toggle chips.
  static const double stadiumRadius = AppRadii.pill;

  /// Corner radius for the optical white barcode/QR presentation container.
  static const double opticalRadius = AppRadii.md;

  /// Corner radius for dialogs and modal confirmation sheets.
  static const double dialogRadius = AppRadii.dialog;

  /// Circular border radius for compact contact cards.
  static const BorderRadius borderCard = BorderRadius.all(
    Radius.circular(cardRadius),
  );

  /// Circular border radius for Codice Fiscale monospace badge pills.
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(pillRadius),
  );

  /// Stadium border radius for buttons and toggle chips.
  static const BorderRadius borderStadium = BorderRadius.all(
    Radius.circular(stadiumRadius),
  );

  /// Circular border radius for optical barcode/QR presentation surfaces.
  static const BorderRadius borderOptical = BorderRadius.all(
    Radius.circular(opticalRadius),
  );

  /// Circular border radius for dialogs and modal confirmation sheets.
  static const BorderRadius borderDialog = BorderRadius.all(
    Radius.circular(dialogRadius),
  );

  /// Thin border stroke width for compact watch cards and pills: 0.8 pt.
  static const double borderThin = AppDimensions.borderThin;

  /// Standard progress indicator stroke width: 2.5 pt.
  static const double progressStrokeWidth = AppDimensions.progressStrokeWidth;

  /// Dialog confirmation button icon size: 20.0 pt.
  static const double dialogActionIconSize = AppDimensions.iconMd;

  // ---------------------------------------------------------------------------
  // Card & Container Sizing
  // ---------------------------------------------------------------------------
  /// Vertical padding for compact contact cards: 7.0 pt.
  static const double cardPaddingVertical = 7.0;

  /// Internal padding for contact cards.
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: cardPaddingVertical,
  );

  /// Vertical margin between cards in the list.
  static const double cardSpacing = AppSpacing.badgeGap;

  /// Internal padding for the Codice Fiscale pill inside the card.
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.badgeGap,
    vertical: AppSpacing.xxs,
  );

  /// Display width and height for optical QR code on watch: 76.0 pt.
  static const double opticalQrSize = 76.0;

  /// Display height for optical 1D barcode on watch: 42.0 pt.
  static const double opticalBarcodeHeight = 42.0;

  /// Padding inside the high-contrast optical white container.
  static const EdgeInsets opticalPadding = EdgeInsets.all(AppSpacing.compact);

  // ---------------------------------------------------------------------------
  // Dialog Insets (Calibrated for Circular Wear OS Displays)
  // ---------------------------------------------------------------------------
  /// Outer dialog insets preventing vertical screen overflow.
  static const EdgeInsets dialogInsetPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.fieldVertical,
    vertical: AppSpacing.sm,
  );

  /// Dialog title padding.
  static const EdgeInsets dialogTitlePadding = EdgeInsets.fromLTRB(
    AppSpacing.fieldVertical,
    AppSpacing.fieldVertical,
    AppSpacing.fieldVertical,
    AppSpacing.badgeGap,
  );

  /// Dialog action buttons row padding.
  static const EdgeInsets dialogActionsPadding = EdgeInsets.fromLTRB(
    AppSpacing.fieldVertical,
    0.0,
    AppSpacing.fieldVertical,
    AppSpacing.sm,
  );

  /// Size of circular touch buttons inside Wear OS dialogs.
  static const double dialogButtonSize = AppDimensions.avatarBadge;

  // ---------------------------------------------------------------------------
  // Interactive Elements & Touch Targets
  // ---------------------------------------------------------------------------
  /// Minimum height for primary buttons on Wear OS.
  static const double buttonHeight = AppDimensions.iconDisplay;

  /// Compact height for secondary/pill buttons.
  static const double buttonCompactHeight = AppDimensions.avatarHeader;

  /// Standard small icon size (e.g. status hints, clock icon).
  static const double iconSmall = AppDimensions.iconXs;

  /// Standard medium icon size (e.g. card icons, actions).
  static const double iconMedium = AppDimensions.iconAction;

  /// Large icon size for empty states and hero badges.
  static const double iconLarge = AppDimensions.iconXl;
}
