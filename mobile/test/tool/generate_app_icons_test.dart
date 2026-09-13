import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('Generate high resolution app icon PNGs from design system', () async {
    // Canvas size
    const size = 1024.0;
    const center = Offset(size / 2, size / 2);

    // Colors from Design System
    const bgDark = Color(0xFF121212);
    const cardBg = Color(0xFF1E1E1E);
    const emerald = Color(0xFF58C878);

    // SVG original coordinates:
    // ViewBox: 512 x 512
    // Card: x=86, y=126, w=340, h=260, r=28, stroke=14
    // Micro chip: line (126,176)-(220,176) w=10, rect x=340, y=166, w=46, h=30, r=6
    // Barcode: rects at y=230, h=110, r=4. x coordinates:
    // 126 (w12), 150 (w22), 184 (w8), 204 (w18), 234 (w28), 274 (w10), 296 (w24), 332 (w14), 358 (w28)

    // Helper to draw card
    void drawCard(Canvas canvas, double scale, {bool monochrome = false}) {
      canvas.save();
      // Translate to center, scale, translate back
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-256, -256);

      final primaryColor = monochrome ? Colors.white : emerald;
      final bodyColor = monochrome ? const Color(0x33FFFFFF) : cardBg;

      // 1. Silhouette Tessera
      final cardRRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(86, 126, 340, 260),
        const Radius.circular(28),
      );

      final cardFillPaint = Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(cardRRect, cardFillPaint);

      final cardStrokePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14;
      canvas.drawRRect(cardRRect, cardStrokePaint);

      // 2. Micro accenti (Banda superiore e chip stilizzato)
      final linePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.4)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(126, 176), const Offset(220, 176), linePaint);

      final chipRRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(340, 166, 46, 30),
        const Radius.circular(6),
      );
      final chipPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(chipRRect, chipPaint);

      // 3. Barcode Geometrico (Altezza identica 110px)
      final barcodeBars = [
        [126.0, 12.0],
        [150.0, 22.0],
        [184.0, 8.0],
        [204.0, 18.0],
        [234.0, 28.0],
        [274.0, 10.0],
        [296.0, 24.0],
        [332.0, 14.0],
        [358.0, 28.0],
      ];

      final barcodePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;

      for (final bar in barcodeBars) {
        final barRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(bar[0], 230, bar[1], 110),
          const Radius.circular(4),
        );
        canvas.drawRRect(barRRect, barcodePaint);
      }

      canvas.restore();
    }

    // 1. Generate full legacy app_icon.png (1024x1024 with dark squircle background)
    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

      // Dark background squircle matching SVG rx="115" at 512 (rx="230" at 1024)
      final bgRRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, size, size),
        const Radius.circular(230),
      );
      final bgPaint = Paint()..color = bgDark;
      canvas.drawRRect(bgRRect, bgPaint);

      // Draw card scaled to 1.6 (balanced legacy icon presentation)
      drawCard(canvas, 1.6);

      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('assets/images/app_icon.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      expect(file.existsSync(), isTrue);
    }

    // 2. Generate adaptive_icon_foreground.png (1024x1024 transparent, scaled for 16% inset)
    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

      // Scale 1.75 ensures the card is prominent and perfectly centered in safe zone after 16% inset
      drawCard(canvas, 1.75);

      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('assets/images/app_icon_foreground.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      expect(file.existsSync(), isTrue);
    }

    // 3. Generate adaptive_icon_monochrome.png (1024x1024 transparent white, for Android 13+ themed icons)
    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

      drawCard(canvas, 1.75, monochrome: true);

      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('assets/images/app_icon_monochrome.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      expect(file.existsSync(), isTrue);
    }
  });
}
