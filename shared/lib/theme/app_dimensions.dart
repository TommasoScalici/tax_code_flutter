import 'package:flutter/widgets.dart';

/// Centralized spacing design tokens following a standard 4pt/8pt grid.
abstract final class AppSpacing {
  /// Micro spacing: 2.0 pt.
  static const double xxs = 2.0;

  /// Extra small spacing: 4.0 pt.
  static const double xs = 4.0;

  /// Badge and inline tag gap: 6.0 pt.
  static const double badgeGap = 6.0;

  /// Badge and compact pill vertical padding: 3.0 pt.
  static const double badgeVertical = 3.0;

  /// Small spacing: 8.0 pt.
  static const double sm = 8.0;

  /// Compact intermediate spacing / tag horizontal padding: 10.0 pt.
  static const double compact = 10.0;

  /// Medium spacing: 12.0 pt.
  static const double md = 12.0;

  /// Standard input and action tile vertical padding: 14.0 pt.
  static const double fieldVertical = 14.0;

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
  /// Uniform insets of 2.0 pt.
  static const EdgeInsets paddingXxs = EdgeInsets.all(xxs);

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
  static const EdgeInsets paddingField = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: fieldVertical,
  );

  /// Standard vertical field and action padding: vertical 14.0 pt.
  static const EdgeInsets paddingFieldVertical = EdgeInsets.symmetric(
    vertical: fieldVertical,
  );

  /// Form field top label insets: left 4.0 pt, bottom 6.0 pt.
  static const EdgeInsets labelPadding = EdgeInsets.only(
    left: xs,
    bottom: badgeGap,
  );

  /// Form field validation error insets: left 8.0 pt, top 6.0 pt.
  static const EdgeInsets errorPadding = EdgeInsets.only(
    left: sm,
    top: badgeGap,
  );

  /// Standard sticky bottom bar padding: horizontal 20.0 pt, vertical 14.0 pt.
  static const EdgeInsets paddingStickyBar = EdgeInsets.symmetric(
    horizontal: card,
    vertical: fieldVertical,
  );

  /// Compact badge padding: horizontal 8.0 pt, vertical 3.0 pt.
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: badgeVertical,
  );
}

/// Centralized corner radius design tokens.
abstract final class AppRadii {
  /// Bottom sheet drag handle radius: 2.0 pt.
  static const double handle = 2.0;

  /// Small chip and badge corner radius: 6.0 pt.
  static const double badge = 6.0;

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

  /// Modal bottom sheet corner radius: 28.0 pt.
  static const double sheet = 28.0;

  /// Stadium border / pill radius: 999.0 pt (buttons, search bars, chips).
  static const double pill = 999.0;

  // ---------------------------------------------------------------------------
  // Standard BorderRadius Presets
  // ---------------------------------------------------------------------------
  /// Circular border radius of 2.0 pt.
  static const BorderRadius borderHandle = BorderRadius.all(
    Radius.circular(handle),
  );

  /// Circular border radius of 6.0 pt for small badges and tags.
  static const BorderRadius borderBadge = BorderRadius.all(
    Radius.circular(badge),
  );

  /// Circular border radius of 8.0 pt.
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

  /// Circular border radius of 10.0 pt.
  static const BorderRadius borderCompact = BorderRadius.all(
    Radius.circular(compact),
  );

  /// Circular border radius of 12.0 pt.
  static const BorderRadius borderInner = BorderRadius.all(
    Radius.circular(inner),
  );

  /// Circular border radius of 14.0 pt.
  static const BorderRadius borderInput = BorderRadius.all(
    Radius.circular(input),
  );

  /// Circular border radius of 16.0 pt.
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));

  /// Circular border radius of 20.0 pt.
  static const BorderRadius borderCard = BorderRadius.all(
    Radius.circular(card),
  );

  /// Circular border radius of 24.0 pt.
  static const BorderRadius borderDialog = BorderRadius.all(
    Radius.circular(dialog),
  );

  /// Modal bottom sheet top rounded border radius: 28.0 pt.
  static const BorderRadius borderSheet = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );

  /// Stadium border radius of 999.0 pt.
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(pill),
  );
}

/// Centralized opacity tokens for consistent alpha channels across dark/light surfaces.
abstract final class AppOpacity {
  /// Extremely faint tint / highlight opacity: 8%.
  static const double tint = 0.08;

  /// Subtle shadow and faint elevation tint: 12%.
  static const double faint = 0.12;

  /// Semi-translucent container fill opacity: 16%.
  static const double semiTranslucent = 0.16;

  /// Subtle glow and primary container tint: 20%.
  static const double glow = 0.20;

  /// Subtle border outline / card stroke opacity: 25%.
  static const double subtleBorder = 0.25;

  /// Translucent badge fill / overlay opacity: 30%.
  static const double translucent = 0.30;

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

  /// Almost opaque surface / glassmorphism opacity: 95%.
  static const double almostOpaque = 0.95;

  /// Translucent glassmorphism surface opacity: 95%.
  static const double surfaceBlur = 0.95;

  /// Floating sticky bottom bar blur surface opacity: 98%.
  static const double stickyBar = 0.98;
}

/// Centralized layout dimensions and touch target constants.
abstract final class AppDimensions {
  /// Hairline stroke width for subtle dividers: 0.5 pt.
  static const double borderHairline = 0.5;

  /// Thin border stroke width for compact cards and pills: 0.8 pt.
  static const double borderThin = 0.8;

  /// Default border stroke width: 1.0 pt.
  static const double borderDefault = 1.0;

  /// Medium card and container border stroke width: 1.2 pt.
  static const double borderMedium = 1.2;

  /// Thick border stroke width for emphasis: 1.5 pt.
  static const double borderThick = 1.5;

  /// Selected border stroke width for active chips/cards: 2.0 pt.
  static const double borderSelected = 2.0;

  /// Standard progress indicator stroke width: 2.5 pt.
  static const double progressStrokeWidth = 2.5;

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

  /// Hero action button height: 56.0 pt.
  static const double heroButtonHeight = 56.0;

  /// Minimum touch target dimension according to accessibility standards: 48.0 pt.
  static const double minTouchTarget = 48.0;

  /// Extra small icon size: 14.0 pt.
  static const double iconXs = 14.0;

  /// Small icon size: 16.0 pt.
  static const double iconSm = 16.0;

  /// Action, trailing, and clear icon size: 18.0 pt.
  static const double iconAction = 18.0;

  /// Medium icon size: 20.0 pt.
  static const double iconMd = 20.0;

  /// Primary button icon or inline loader size: 22.0 pt.
  static const double iconButton = 22.0;

  /// Large icon size: 24.0 pt.
  static const double iconLg = 24.0;

  /// Extra large icon size: 32.0 pt.
  static const double iconXl = 32.0;

  /// Display illustration / empty state icon size: 40.0 pt.
  static const double iconDisplay = 40.0;

  /// Hero illustration / permission icon size: 48.0 pt.
  static const double iconHero = 48.0;

  /// Compact header avatar size: 34.0 pt.
  static const double avatarHeader = 34.0;

  /// Circular status / indicator avatar size: 36.0 pt.
  static const double avatarBadge = 36.0;

  /// Square brand app logo container size: 54.0 pt.
  static const double avatarBrand = 54.0;

  /// Empty state icon container dimension: 88.0 pt.
  static const double iconIllustrationContainer = 88.0;

  /// Compact button height: 44.0 pt.
  static const double buttonHeightCompact = 44.0;

  /// Segmented button interactive row height: 42.0 pt.
  static const double segmentedHeight = 42.0;

  /// Standard maximum container width for forms, sheets, and cards: 520.0 pt.
  static const double maxContentWidth = 520.0;

  /// Maximum dashboard content width on wide displays: 600.0 pt.
  static const double maxDashboardWidth = 600.0;

  /// Maximum welcome and authentication card width: 480.0 pt.
  static const double maxWelcomeWidth = 480.0;

  /// Maximum empty state container width: 420.0 pt.
  static const double maxEmptyStateWidth = 420.0;

  /// Maximum dropdown autocomplete overlay width: 360.0 pt.
  static const double maxDropdownWidth = 360.0;

  /// Maximum dropdown autocomplete overlay height: 250.0 pt.
  static const double maxDropdownHeight = 250.0;

  /// Maximum subtitle text block width: 320.0 pt.
  static const double maxSubtitleWidth = 320.0;

  /// Large hero logo or brand badge dimension: 120.0 pt.
  static const double heroLogo = 120.0;

  /// Secondary camera retake button icon size: 28.0 pt.
  static const double iconFabRetake = 28.0;

  /// Primary camera action / shutter button icon size: 36.0 pt.
  static const double iconFabCapture = 36.0;

  /// Bottom sheet theme drag handle width: 36.0 pt.
  static const double dragHandleThemeWidth = 36.0;

  /// 1D linear barcode height on mobile displays: 72.0 pt.
  static const double barcodeHeight = 72.0;

  /// 2D QR code display box dimension on mobile displays: 110.0 pt.
  static const double qrCodeSize = 110.0;

  /// Bottom sheet theme drag handle size preset: 36.0 x 4.0 pt.
  static const Size dragHandleThemeSize = Size(
    dragHandleThemeWidth,
    dragHandleHeight,
  );
}

/// Centralized typographic font size constants.
abstract final class AppFontSizes {
  /// Wear OS micro caption font size: 9.5 pt.
  static const double watchMicro = 9.5;

  /// Micro badge and pill label font size: 10.0 pt.
  static const double micro = 10.0;

  /// Wear OS small body / caption font size: 10.5 pt.
  static const double watchCaption = 10.5;

  /// Small metadata and caption font size: 11.0 pt.
  static const double caption = 11.0;

  /// Wear OS small title font size: 11.5 pt.
  static const double watchTitleSm = 11.5;

  /// Secondary body text font size: 12.0 pt.
  static const double bodySm = 12.0;

  /// Wear OS medium title / clock header font size: 12.5 pt.
  static const double watchTitleMd = 12.5;

  /// Compact title / secondary action font size: 13.0 pt.
  static const double titleSm = 13.0;

  /// Standard body font size: 14.0 pt.
  static const double bodyMd = 14.0;

  /// Input field and emphasized body font size: 15.0 pt.
  static const double input = 15.0;

  /// Standard card title / large body font size: 16.0 pt.
  static const double bodyLg = 16.0;

  /// Large card title / preview code font size: 17.0 pt.
  static const double cardTitle = 17.0;

  /// Section heading font size: 18.0 pt.
  static const double headlineSm = 18.0;

  /// Prominent card / modal heading font size: 20.0 pt.
  static const double headlineMd = 20.0;

  /// Prominent fiscal code display font size: 22.0 pt.
  static const double codeDisplay = 22.0;

  /// Large headline and small display font size: 24.0 pt.
  static const double headlineLg = 24.0;

  /// Medium display font size: 30.0 pt.
  static const double displayMd = 30.0;

  /// Large hero display font size: 36.0 pt.
  static const double displayLg = 36.0;
}

/// Centralized typographic letter spacing design tokens.
abstract final class AppLetterSpacing {
  /// Large display headline tracking: -0.8 pt.
  static const double displayLg = -0.8;

  /// Medium headline / welcome title tracking: -0.5 pt.
  static const double headlineTight = -0.5;

  /// Prominent section header tracking: -0.3 pt.
  static const double heading = -0.3;

  /// Subtle negative tracking for titles and cards: -0.2 pt.
  static const double titleTight = -0.2;

  /// Snug negative tracking for compact cards and headers: -0.1 pt.
  static const double snug = -0.1;

  /// Minimal positive tracking: 0.1 pt.
  static const double micro = 0.1;

  /// Subtle positive tracking for actions and search: 0.2 pt.
  static const double subtle = 0.2;

  /// Subtle positive tracking for small labels and badges: 0.3 pt.
  static const double tracked = 0.3;

  /// Standard label tracking: 0.4 pt.
  static const double label = 0.4;

  /// Caption tracking: 0.6 pt.
  static const double caption = 0.6;

  /// Tag, pill, and badge tracking: 0.8 pt.
  static const double badge = 0.8;

  /// Standard monospaced code tracking: 1.0 pt.
  static const double code = 1.0;

  /// Compact optical code tracking: 1.1 pt.
  static const double codeCompact = 1.1;

  /// Uppercase section header tracking: 1.2 pt.
  static const double uppercase = 1.2;

  /// Wide tracking: 1.4 pt.
  static const double wide = 1.4;

  /// Card monospaced code tracking: 1.6 pt.
  static const double codeCard = 1.6;

  /// Display monospaced code tracking: 2.0 pt.
  static const double codeDisplay = 2.0;

  /// Optical barcode readable text tracking: 2.2 pt.
  static const double barcode = 2.2;
}

/// Centralized typographic line height multipliers.
abstract final class AppLineHeights {
  /// Compact header line height: 1.1.
  static const double headerCompact = 1.1;

  /// Snug heading line height: 1.2.
  static const double heading = 1.2;

  /// Display code and title line height: 1.25.
  static const double displayCode = 1.25;

  /// Code and caption line height: 1.3.
  static const double code = 1.3;

  /// Balanced heading line height: 1.35.
  static const double headingMd = 1.35;

  /// Standard reading line height: 1.4.
  static const double body = 1.4;

  /// Relaxed body text line height: 1.45.
  static const double relaxed = 1.45;

  /// Generous body reading line height: 1.5.
  static const double comfortable = 1.5;
}

/// Centralized elevation design tokens according to Material 3 specifications.
abstract final class AppElevation {
  /// Flat surface with zero elevation: 0.0 pt.
  static const double none = 0.0;

  /// Low elevation for resting cards and buttons: 2.0 pt.
  static const double level1 = 2.0;

  /// Hover elevation for buttons and interactive controls: 3.0 pt.
  static const double levelHover = 3.0;

  /// Medium elevation for floating controls: 4.0 pt.
  static const double level2 = 4.0;

  /// Prominent elevation for autocomplete dropdowns: 6.0 pt.
  static const double level3 = 6.0;

  /// High elevation for dialogs and pickers: 8.0 pt.
  static const double dialog = 8.0;

  /// Modal elevation for bottom sheets: 16.0 pt.
  static const double modal = 16.0;
}
