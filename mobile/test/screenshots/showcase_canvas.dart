import 'package:flutter/material.dart';

enum ShowcaseDeviceType {
  phone,
  tablet7,
  tablet10,
}

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
    required this.deviceScale,
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
  final double deviceScale;

  static const phone = ShowcaseDeviceSpec(
    canvasWidth: 1080,
    canvasHeight: 2400,
    deviceWidth: 840,
    deviceHeight: 1820,
    deviceBorderRadius: 54,
    deviceBezelWidth: 12,
    headlineFontSize: 46,
    subtitleFontSize: 24,
    headerPaddingTop: 80,
    headerPaddingBottom: 40,
    deviceScale: 2.1,
  );

  static const tablet7 = ShowcaseDeviceSpec(
    canvasWidth: 1200,
    canvasHeight: 1920,
    deviceWidth: 1020,
    deviceHeight: 1400,
    deviceBorderRadius: 40,
    deviceBezelWidth: 14,
    headlineFontSize: 44,
    subtitleFontSize: 22,
    headerPaddingTop: 70,
    headerPaddingBottom: 35,
    deviceScale: 1.7,
  );

  static const tablet10 = ShowcaseDeviceSpec(
    canvasWidth: 1600,
    canvasHeight: 2560,
    deviceWidth: 1360,
    deviceHeight: 1880,
    deviceBorderRadius: 44,
    deviceBezelWidth: 16,
    headlineFontSize: 54,
    subtitleFontSize: 28,
    headerPaddingTop: 90,
    headerPaddingBottom: 45,
    deviceScale: 2.1,
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
    super.key,
  });

  final ShowcaseDeviceSpec spec;
  final String headline;
  final String subtitle;
  final Widget child;

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
                      const SizedBox(height: 14),
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
                        child: Stack(
                          children: [
                            // App Content
                            Positioned.fill(child: child),

                            // Camera notch / punch hole indicator (for phone)
                            if (spec == ShowcaseDeviceSpec.phone)
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width: 120,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B0F19),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
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
