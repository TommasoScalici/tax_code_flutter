import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders a modern, high-conversion Google Play Store Feature Graphic (1024x500).
/// Strictly adheres to the Google Play Safe Zone (leaving ~125px margins left/right)
/// and utilizes the official app icon for consistent brand identity.
class FeatureGraphicCanvas extends StatelessWidget {
  const FeatureGraphicCanvas({
    required this.isItalian,
    this.iconImage,
    super.key,
  });

  final bool isItalian;
  final ui.Image? iconImage;

  @override
  Widget build(BuildContext context) {
    final titleText = isItalian ? 'Codice Fiscale' : 'Tax Code';
    final subtitleText = isItalian
        ? 'Calcolo istantaneo, scanner IA e gestione tessere'
        : 'Instant calculation, AI scanner and cards management';
    final badgeText = isItalian
        ? 'SCANNER IA & BACKUP CLOUD'
        : 'AI SCANNER & CLOUD BACKUP';
    final chips = isItalian
        ? ['100% Offline', 'Scanner IA', 'Barcode & QR', 'Wear OS']
        : ['100% Offline', 'AI Scanner', 'Barcode & QR', 'Wear OS'];

    return Container(
      width: 1024,
      height: 500,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF070D18)],
        ),
      ),
      child: Stack(
        children: [
          // Background ambient glows
          Positioned(
            left: 20,
            top: 50,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: -60,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF065F46).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Centered Safe Zone container (horizontal margin ~125px ensures no crop in 16:9)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Brand App Icon
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.28),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: iconImage != null
                          ? RawImage(
                              image: iconImage,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  const SizedBox(width: 44),

                  // Information (Right)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill Badge (Active indicator + practical value proposition)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF34D399),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                badgeText,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF34D399),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title
                        Text(
                          titleText,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.6,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Color(0x99000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          subtitleText,
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFCBD5E1),
                            height: 1.3,
                            letterSpacing: 0.1,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Feature Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final chip in chips)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF1F5F9),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Generate high-conversion Google Play Store Feature Graphics', (
    tester,
  ) async {
    ui.Image? iconImage;

    await tester.runAsync(() async {
      final interFiles = [
        'assets/fonts/Inter-Regular.ttf',
        'assets/fonts/Inter-Medium.ttf',
        'assets/fonts/Inter-SemiBold.ttf',
        'assets/fonts/Inter-Bold.ttf',
      ];

      for (final family in ['Inter', 'Arial', 'Roboto']) {
        final loader = FontLoader(family);
        for (final path in interFiles) {
          final file = File(path);
          if (file.existsSync()) {
            final data = await file.readAsBytes();
            loader.addFont(Future.value(ByteData.sublistView(data)));
          }
        }
        await loader.load();
      }

      final iconFile = File('assets/images/play_store_icon.png');
      if (iconFile.existsSync()) {
        final bytes = await iconFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        iconImage = frame.image;
      }
    });

    final targets = {
      'it': 'assets/images/feature_graphic_it.png',
      'en': 'assets/images/feature_graphic_en.png',
    };

    tester.view.physicalSize = const Size(1024, 500);
    tester.view.devicePixelRatio = 1.0;
    await tester.binding.setSurfaceSize(const Size(1024, 500));

    for (final entry in targets.entries) {
      final isIt = entry.key == 'it';
      final relativePath = entry.value;
      final repaintKey = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: repaintKey,
            child: FeatureGraphicCanvas(isItalian: isIt, iconImage: iconImage),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final boundary =
            repaintKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final targetFile = File(relativePath);
        await targetFile.writeAsBytes(bytes);

        expect(targetFile.existsSync(), isTrue);
        expect(bytes.length, greaterThan(5000));
      });
    }

    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });
  });
}
