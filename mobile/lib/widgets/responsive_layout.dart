import 'package:material_ui/material_ui.dart';

/// A responsive wrapper widget designed to adapt layout across mobile phones,
/// foldable devices, and tablets.
///
/// Prevents excessive horizontal stretching on large displays by centering the content
/// and constraining it to a readable [maxWidth] (default: 560px), while maintaining
/// consistent 20px edge gutters and optional [SafeArea] ergonomics.
class ResponsiveLayout extends StatelessWidget {
  /// Default breakpoint (in logical pixels) separating compact mobile from tablet/foldable.
  static const double mobileBreakpoint = 600.0;

  /// Default breakpoint (in logical pixels) separating tablet from desktop.
  static const double desktopBreakpoint = 1024.0;

  /// Default maximum content width to prevent horizontal stretching.
  static const double defaultMaxWidth = 560.0;

  /// Default padding matching the Emerald Ledger design system.
  static const EdgeInsets defaultPadding =
      EdgeInsets.symmetric(horizontal: 20.0);

  /// Creates a [ResponsiveLayout] with a static [child].
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = defaultMaxWidth,
    this.padding = defaultPadding,
    this.useSafeArea = true,
    this.center = true,
  }) : builder = null;

  /// Creates an adaptive [ResponsiveLayout] using a builder callback that
  /// supplies the layout constraint and a boolean indicating wide screen mode.
  const ResponsiveLayout.builder({
    super.key,
    required Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      bool isWide,
    )
    this.builder,
    this.maxWidth = defaultMaxWidth,
    this.padding = defaultPadding,
    this.useSafeArea = true,
    this.center = true,
  }) : child = null;

  /// Static widget to render inside the constrained area.
  final Widget? child;

  /// Optional builder function for responsive slot adaptations.
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    bool isWide,
  )?
  builder;

  /// The maximum width allowed for the content.
  final double maxWidth;

  /// The horizontal and vertical padding around the content.
  final EdgeInsetsGeometry padding;

  /// Whether to wrap the content inside a [SafeArea].
  final bool useSafeArea;

  /// Whether to center the constrained content horizontally on screens wider than [maxWidth].
  final bool center;

  /// Convenience utility checking if the current window is classified as mobile (< 600px).
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Convenience utility checking if the current window is classified as tablet/foldable (>= 600px and < 1024px).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Convenience utility checking if the current window is wide (>= 600px).
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isWideScreen = screenWidth >= mobileBreakpoint;

        Widget content = Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: builder != null
                ? builder!(context, constraints, isWideScreen)
                : child!,
          ),
        );

        if (center) {
          content = Center(
            child: content,
          );
        }

        if (useSafeArea) {
          content = SafeArea(
            child: content,
          );
        }

        return content;
      },
    );
  }
}
