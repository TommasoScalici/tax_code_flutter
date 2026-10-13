import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders a modern, high-conversion Google Play Store Feature Graphic (1024x500).
/// Strictly adheres to the Google Play Safe Zone (leaving ~110px margins left/right)
/// so that nothing gets clipped when displayed in search cards (16:9) or on tablets.
class FeatureGraphicCanvas extends StatelessWidget {
  const FeatureGraphicCanvas({required this.isItalian, super.key});

  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    final titleText = isItalian ? 'Codice Fiscale' : 'Tax Code';
    final subtitleText = isItalian
        ? 'Calcolo istantaneo, scanner IA e backup cloud'
        : 'Instant calculation, AI scanner and cloud backup';
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
          colors: [Color(0xFF0F172A), Color(0xFF060B14)],
        ),
      ),
      child: Stack(
        children: [
          // Background ambient glows
          Positioned(
            left: -80,
            top: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -60,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF065F46).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Safe Zone Container (horizontal padding ~100px so content is never cropped in 16:9)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Card Icon (Left)
                  Container(
                    width: 170,
                    height: 230,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF34D399).withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.25),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip icon & Brand badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 38,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAB308),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const Text(
                              'CF',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                        // Barcode mockup
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _BarcodeBar(width: 4),
                              _BarcodeGap(width: 3),
                              _BarcodeBar(width: 6),
                              _BarcodeGap(width: 2),
                              _BarcodeBar(width: 3),
                              _BarcodeGap(width: 4),
                              _BarcodeBar(width: 7),
                              _BarcodeGap(width: 2),
                              _BarcodeBar(width: 4),
                              _BarcodeGap(width: 3),
                              _BarcodeBar(width: 8),
                              _BarcodeGap(width: 2),
                              _BarcodeBar(width: 3),
                              _BarcodeGap(width: 4),
                              _BarcodeBar(width: 5),
                              _BarcodeGap(width: 2),
                              _BarcodeBar(width: 4),
                            ],
                          ),
                        ),
                      ],
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
                            fontSize: 52,
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
                            fontSize: 18.5,
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

class _BarcodeBar extends StatelessWidget {
  const _BarcodeBar({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF34D399),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

class _BarcodeGap extends StatelessWidget {
  const _BarcodeGap({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}

void main() {
  testWidgets('Generate high-conversion Google Play Store Feature Graphics', (
    tester,
  ) async {
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
            child: FeatureGraphicCanvas(isItalian: isIt),
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
