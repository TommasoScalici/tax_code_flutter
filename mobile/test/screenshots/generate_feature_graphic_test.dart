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
          // Centered Safe Zone container (horizontal margin 72px ensures no crop even in 16:9)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Brand App Icon
                  Container(
                    width: 288,
                    height: 288,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(64),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.32),
                          blurRadius: 48,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: iconImage != null
                          ? RawImage(
                              image: iconImage,
                              width: 288,
                              height: 288,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Information (Right)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill Badge (Active indicator + practical value proposition)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.65),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
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
                              const SizedBox(width: 10),
                              Text(
                                badgeText,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF34D399),
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          titleText,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 66,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            height: 1.06,
                            shadows: [
                              Shadow(
                                color: Color(0x99000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          subtitleText,
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE2E8F0),
                            height: 1.28,
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

                        const SizedBox(height: 22),

                        // Feature Chips (2x2 Grid with aligned columns)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _FeatureChip(label: chips[0]),
                                  const SizedBox(height: 12),
                                  _FeatureChip(label: chips[2]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _FeatureChip(label: chips[1]),
                                  const SizedBox(height: 12),
                                  _FeatureChip(label: chips[3]),
                                ],
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

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
          letterSpacing: 0.2,
        ),
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
