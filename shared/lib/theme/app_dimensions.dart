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

  /// Uniform insets of 24.0 pt.
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Uniform insets of 32.0 pt.
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  /// Standard horizontal screen margin of 16.0 pt.
  static const EdgeInsets screenMargin = EdgeInsets.symmetric(horizontal: lg);
}

/// Centralized corner radius design tokens.
abstract final class AppRadii {
  /// Small radius: 8.0 pt (chips, small badges, inline tags).
  static const double sm = 8.0;

  /// Medium radius: 16.0 pt (interactive form cards, input fields).
  static const double md = 16.0;

  /// Standard card radius: 20.0 pt (contact cards, hero banners).
  static const double card = 20.0;

  /// Dialog and modal sheet radius: 24.0 pt.
  static const double dialog = 24.0;

  /// Stadium border / pill radius: 999.0 pt (buttons, search bars, chips).
  static const double pill = 999.0;

  // ---------------------------------------------------------------------------
  // Standard BorderRadius Presets
  // ---------------------------------------------------------------------------
  /// Circular border radius of 8.0 pt.
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

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
  /// Disabled element opacity: 38%.
  static const double disabled = 0.38;

  /// Subtle hint / outline opacity: 55%.
  static const double subtle = 0.55;

  /// Medium secondary contrast opacity: 70%.
  static const double medium = 0.70;

  /// High prominence text / element opacity: 85%.
  static const double high = 0.85;
}

/// Centralized layout dimensions and touch target constants.
abstract final class AppDimensions {
  /// Minimum touch target dimension according to accessibility standards: 48.0 pt.
  static const double minTouchTarget = 48.0;

  /// Small icon size: 16.0 pt.
  static const double iconSm = 16.0;

  /// Medium icon size: 20.0 pt.
  static const double iconMd = 20.0;

  /// Large icon size: 24.0 pt.
  static const double iconLg = 24.0;

  /// Extra large icon size: 32.0 pt.
  static const double iconXl = 32.0;
}
