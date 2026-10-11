import 'package:flutter/widgets.dart';

/// Centralized spacing design tokens following a standard 4pt/8pt grid.
abstract final class AppSpacing {
  /// Extra small spacing: 4.0 pt.
  static const double xs = 4.0;

  /// Small spacing: 8.0 pt.
  static const double sm = 8.0;

  /// Medium spacing: 12.0 pt.
  static const double md = 12.0;

  /// Large spacing: 16.0 pt.
  static const double lg = 16.0;

  /// Card internal padding / content gap: 20.0 pt.
  static const double card = 20.0;

  /// Extra large spacing: 24.0 pt.
  static const double xl = 24.0;

  /// Double extra large spacing: 32.0 pt.
  static const double xxl = 32.0;

  // ---------------------------------------------------------------------------
  // Standard Insets Presets
  // ---------------------------------------------------------------------------
  /// Uniform insets of 4.0 pt.
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Uniform insets of 8.0 pt.
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Uniform insets of 12.0 pt.
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Uniform insets of 16.0 pt.
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Uniform insets of 20.0 pt (standard card body padding).
  static const EdgeInsets paddingCard = EdgeInsets.all(card);

  /// Uniform insets of 24.0 pt.
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Uniform insets of 32.0 pt.
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  /// Standard horizontal screen margin of 16.0 pt.
  static const EdgeInsets screenMargin = EdgeInsets.symmetric(horizontal: lg);

  /// Standard input and action tile padding: horizontal 16.0 pt, vertical 14.0 pt.
  static const EdgeInsets paddingField = EdgeInsets.symmetric(horizontal: lg, vertical: 14.0);
}

/// Centralized corner radius design tokens.
abstract final class AppRadii {
  /// Bottom sheet drag handle radius: 2.0 pt.
  static const double handle = 2.0;

  /// Small radius: 8.0 pt (chips, small badges, inline tags).
  static const double sm = 8.0;

  /// Compact / inner badge radius: 10.0 pt (segmented button items).
  static const double compact = 10.0;

  /// Inner element radius: 12.0 pt (icon container badges, sub-cards).
  static const double inner = 12.0;

  /// Input / interactive field radius: 14.0 pt (text fields, segmented buttons, code boxes).
  static const double input = 14.0;

  /// Medium radius: 16.0 pt (interactive form cards, input fields).
  static const double md = 16.0;

  /// Standard card radius: 20.0 pt (contact cards, hero banners, section containers).
  static const double card = 20.0;

  /// Dialog and modal sheet radius: 24.0 pt.
  static const double dialog = 24.0;

  /// Stadium border / pill radius: 999.0 pt (buttons, search bars, chips).
  static const double pill = 999.0;

  // ---------------------------------------------------------------------------
  // Standard BorderRadius Presets
  // ---------------------------------------------------------------------------
  /// Circular border radius of 2.0 pt.
  static const BorderRadius borderHandle = BorderRadius.all(Radius.circular(handle));

  /// Circular border radius of 8.0 pt.
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

  /// Circular border radius of 10.0 pt.
  static const BorderRadius borderCompact = BorderRadius.all(Radius.circular(compact));

  /// Circular border radius of 12.0 pt.
  static const BorderRadius borderInner = BorderRadius.all(Radius.circular(inner));

  /// Circular border radius of 14.0 pt.
  static const BorderRadius borderInput = BorderRadius.all(Radius.circular(input));

  /// Circular border radius of 16.0 pt.
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));

  /// Circular border radius of 20.0 pt.
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(card));

  /// Circular border radius of 24.0 pt.
  static const BorderRadius borderDialog = BorderRadius.all(Radius.circular(dialog));

  /// Stadium border radius of 999.0 pt.
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(pill));
}

/// Centralized opacity tokens for consistent alpha channels across dark/light surfaces.
abstract final class AppOpacity {
  /// Subtle shadow and faint elevation tint: 12%.
  static const double faint = 0.12;

  /// Subtle glow and primary container tint: 20%.
  static const double glow = 0.20;

  /// Disabled element opacity: 38%.
  static const double disabled = 0.38;

  /// Subtle border outline opacity: 40%.
  static const double outline = 0.40;

  /// Balanced divider and border opacity: 50%.
  static const double divider = 0.50;

  /// Subtle hint / outline opacity: 55%.
  static const double subtle = 0.55;

  /// Muted secondary text and icon opacity: 60%.
  static const double muted = 0.60;

  /// Medium secondary contrast opacity: 70%.
  static const double medium = 0.70;

  /// Prominent element and active icon opacity: 75%.
  static const double prominent = 0.75;

  /// High prominence text / element opacity: 85%.
  static const double high = 0.85;

  /// Translucent glassmorphism surface opacity: 95%.
  static const double surfaceBlur = 0.95;
}

/// Centralized layout dimensions and touch target constants.
abstract final class AppDimensions {
  /// Drag handle width for bottom sheets: 32.0 pt.
  static const double dragHandleWidth = 32.0;

  /// Drag handle height for bottom sheets: 4.0 pt.
  static const double dragHandleHeight = 4.0;

  /// Small avatar or tile icon size: 38.0 pt.
  static const double avatarSm = 38.0;

  /// Medium avatar size: 48.0 pt.
  static const double avatarMd = 48.0;

  /// Large profile avatar size: 58.0 pt.
  static const double avatarLg = 58.0;

  /// Search bar fixed height: 50.0 pt.
  static const double searchBarHeight = 50.0;

  /// Primary button height: 52.0 pt.
  static const double primaryButtonHeight = 52.0;

  /// Minimum touch target dimension according to accessibility standards: 48.0 pt.
  static const double minTouchTarget = 48.0;

  /// Extra small icon size: 14.0 pt.
  static const double iconXs = 14.0;

  /// Small icon size: 16.0 pt.
  static const double iconSm = 16.0;

  /// Medium icon size: 20.0 pt.
  static const double iconMd = 20.0;

  /// Large icon size: 24.0 pt.
  static const double iconLg = 24.0;

  /// Extra large icon size: 32.0 pt.
  static const double iconXl = 32.0;
}
