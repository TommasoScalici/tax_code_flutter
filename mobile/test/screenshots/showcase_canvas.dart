import 'package:flutter/material.dart';

/// Supported device types for store showcases.
enum ShowcaseDeviceType {
  phone,
  tablet7,
  tablet10,
}

/// Specifications for each device form-factor showcase.
class ShowcaseDeviceSpec {
  const ShowcaseDeviceSpec({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.deviceBorderRadius,
    required this.deviceBezelWidth,
    required this.headlineFontSize,
    required this.subtitleFontSize,
    required this.headerPaddingTop,
    required this.headerPaddingBottom,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.statusBarHeight,
    required this.navigationBarHeight,
    this.isTablet = false,
  });

  final double canvasWidth;
  final double canvasHeight;
  final double deviceWidth;
  final double deviceHeight;
  final double deviceBorderRadius;
  final double deviceBezelWidth;
  final double headlineFontSize;
  final double subtitleFontSize;
  final double headerPaddingTop;
  final double headerPaddingBottom;
  final double logicalWidth;
  final double logicalHeight;
  final double statusBarHeight;
  final double navigationBarHeight;
  final bool isTablet;

  static const phone = ShowcaseDeviceSpec(
    canvasWidth: 1080,
    canvasHeight: 2400,
    deviceWidth: 930,
    deviceHeight: 2050,
    deviceBorderRadius: 52,
    deviceBezelWidth: 12,
    headlineFontSize: 42,
    subtitleFontSize: 22,
    headerPaddingTop: 64,
    headerPaddingBottom: 28,
    logicalWidth: 412,
    logicalHeight: 915,
    statusBarHeight: 44,
    navigationBarHeight: 24,
  );

  static const tablet7 = ShowcaseDeviceSpec(
    canvasWidth: 1200,
    canvasHeight: 1920,
    deviceWidth: 1040,
    deviceHeight: 1650,
    deviceBorderRadius: 36,
    deviceBezelWidth: 14,
    headlineFontSize: 40,
    subtitleFontSize: 20,
    headerPaddingTop: 54,
    headerPaddingBottom: 24,
    logicalWidth: 600,
    logicalHeight: 960,
    statusBarHeight: 36,
    navigationBarHeight: 20,
    isTablet: true,
  );

  static const tablet10 = ShowcaseDeviceSpec(
    canvasWidth: 1600,
    canvasHeight: 2560,
    deviceWidth: 1380,
    deviceHeight: 2180,
    deviceBorderRadius: 40,
    deviceBezelWidth: 16,
    headlineFontSize: 50,
    subtitleFontSize: 24,
    headerPaddingTop: 70,
    headerPaddingBottom: 32,
    logicalWidth: 800,
    logicalHeight: 1280,
    statusBarHeight: 40,
    navigationBarHeight: 24,
    isTablet: true,
  );
}

/// A marketing showcase canvas for Google Play Store screenshots.
/// Renders an eye-catching gradient backdrop, localized headlines, and an
/// elegant hardware mockup framing the actual Flutter application screen.
class StoreShowcaseCanvas extends StatelessWidget {
  const StoreShowcaseCanvas({
    required this.spec,
    required this.headline,
    required this.subtitle,
    required this.child,
    this.isDark = false,
    super.key,
  });

  final ShowcaseDeviceSpec spec;
  final String headline;
  final String subtitle;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: spec.canvasWidth,
      height: spec.canvasHeight,
      child: Stack(
        children: [
          // 1. Deep sapphire and indigo gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09121D),
                    Color(0xFF0E1E32),
                    Color(0xFF162D4A),
                    Color(0xFF1A365D),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle top ambient glow
                  Positioned(
                    top: -150,
                    left: spec.canvasWidth / 2 - 350,
                    width: 700,
                    height: 500,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF2563EB).withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Subtle bottom device glow
                  Positioned(
                    bottom: 0,
                    left: spec.canvasWidth / 2 - 450,
                    width: 900,
                    height: 900,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1D4ED8).withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Column: Header text + Device Mockup
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: spec.headerPaddingTop),

                // Promotional Headline & Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: spec.headlineFontSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.15,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: spec.subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE2E8F0),
                          letterSpacing: 0.1,
                          height: 1.35,
                          shadows: const [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spec.headerPaddingBottom),

                // 3. Device Mockup
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: spec.deviceWidth,
                      height: spec.deviceHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(
                          spec.deviceBorderRadius,
                        ),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: spec.deviceBezelWidth,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x8A000000),
                            blurRadius: 48,
                            spreadRadius: 4,
                            offset: Offset(0, 24),
                          ),
                          BoxShadow(
                            color: Color(0x3338BDF8),
                            blurRadius: 36,
                            spreadRadius: -8,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          spec.deviceBorderRadius - spec.deviceBezelWidth,
                        ),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox(
                            width: spec.logicalWidth,
                            height: spec.logicalHeight,
                            child: MediaQuery(
                              data: MediaQueryData(
                                size: Size(
                                  spec.logicalWidth,
                                  spec.logicalHeight,
                                ),
                                padding: EdgeInsets.only(
                                  top: spec.statusBarHeight,
                                  bottom: spec.navigationBarHeight,
                                ),
                                viewPadding: EdgeInsets.only(
                                  top: spec.statusBarHeight,
                                  bottom: spec.navigationBarHeight,
                                ),
                                devicePixelRatio: 2.625,
                              ),
                              child: Stack(
                                children: [
                                  // The application screen
                                  Positioned.fill(child: child),

                                  // Realistic Android Status Bar
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: spec.statusBarHeight,
                                    child: _DeviceStatusBar(
                                      spec: spec,
                                      isDark: isDark,
                                    ),
                                  ),

                                  // Realistic Android gesture navigation pill
                                  Positioned(
                                    bottom: 6,
                                    left: spec.logicalWidth / 2 - 36,
                                    width: 72,
                                    height: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusBar extends StatelessWidget {
  const _DeviceStatusBar({
    required this.spec,
    this.isDark = false,
  });

  final ShowcaseDeviceSpec spec;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : const Color(0xFF1E293B);

    return SizedBox(
      height: spec.statusBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // System Clock
            Text(
              '09:41',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.2,
              ),
            ),

            // Camera punch-hole in the status bar center (for phone)
            if (!spec.isTablet)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.5,
                  ),
                ),
              ),

            // System icons: Wifi, Signal, Battery
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.battery_full_rounded,
                  size: 17,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
