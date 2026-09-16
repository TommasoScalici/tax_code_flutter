import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Contract for generating high-resolution PNG images of a [Contact]'s card.
abstract class ContactCardImageServiceAbstract {
  /// Generates the raw PNG image bytes for [contact].
  Future<Uint8List> generateCardImage({
    required Contact contact,
    AppLocalizations? l10n,
    String? footerText,
  });
}

/// Concrete implementation of [ContactCardImageServiceAbstract] producing
/// high-resolution 1200x750 PNG cards with 1D Barcode and 2D QR Code.
class ContactCardImageService implements ContactCardImageServiceAbstract {
  /// Creates a [ContactCardImageService].
  const ContactCardImageService();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Future<Uint8List> generateCardImage({
    required Contact contact,
    AppLocalizations? l10n,
    String? footerText,
  }) async {
    const width = 1200.0;
    const height = 760.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    _paintCard(canvas, const Size(width, height), contact, l10n, footerText);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _paintCard(
    Canvas canvas,
    Size size,
    Contact contact,
    AppLocalizations? l10n,
    String? footerText,
  ) {
    final effectiveL10n = l10n ?? AppLocalizationsEn();

    // 1. Background fill
    final bgPaint = Paint()..color = AppColors.darkBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Card Container (Outer Margin: 24px)
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 24, size.width - 48, size.height - 48),
      const Radius.circular(28),
    );

    // Card background gradient
    final cardGradient = ui.Gradient.linear(
      const Offset(24, 24),
      Offset(24, size.height - 24),
      const [
        AppColors.darkSurfaceContainer,
        AppColors.darkBackground,
      ],
    );
    final cardPaint = Paint()..shader = cardGradient;
    canvas.drawRRect(cardRect, cardPaint);

    // Card border
    final borderPaint = Paint()
      ..color = AppColors.emeraldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cardRect, borderPaint);

    // 3. Top Header: Category Pill & Brand Name
    _drawText(
      canvas: canvas,
      text: effectiveL10n.cardRepublicHeader,
      offset: const Offset(56, 56),
      style: const TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );

    _drawText(
      canvas: canvas,
      text: effectiveL10n.cardPersonalCardHeader,
      offset: const Offset(960, 56),
      style: const TextStyle(
        color: AppColors.emeraldPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );

    // 4. Contact Name (Uppercase, Large Bold)
    final fullName = '${contact.firstName} ${contact.lastName}'.toUpperCase();
    _drawText(
      canvas: canvas,
      text: fullName.isNotEmpty ? fullName : effectiveL10n.cardCitizenFallback,
      offset: const Offset(56, 92),
      style: const TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );

    // 5. Tax Code Highlight Container
    final taxCodeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(56, 155, 1088, 80),
      const Radius.circular(16),
    );
    final taxCodeBgPaint = Paint()..color = AppColors.brandGradientStart;
    canvas.drawRRect(taxCodeRect, taxCodeBgPaint);

    final taxCodeBorderPaint = Paint()
      ..color = AppColors.emeraldPrimary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(taxCodeRect, taxCodeBorderPaint);

    _drawText(
      canvas: canvas,
      text: contact.taxCode,
      offset: const Offset(84, 172),
      style: AppTypography.codeDisplay(
        color: AppColors.emeraldLight,
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: 5.0,
      ),
    );

    // 6. Demographic details row
    final birthDateStr = _dateFormat.format(contact.birthDate);
    final birthplaceStr = contact.birthPlace.state.isNotEmpty
        ? '${contact.birthPlace.name} (${contact.birthPlace.state})'
        : contact.birthPlace.name;
    final belfioreStr = contact.birthPlace.code;

    final details = [
      (
        effectiveL10n.gender.toUpperCase(),
        contact.gender.isNotEmpty ? contact.gender : '-',
      ),
      (effectiveL10n.cardBornOnLabel, birthDateStr),
      (
        effectiveL10n.cardMunicipalityCountryLabel,
        birthplaceStr.isNotEmpty ? birthplaceStr : '-',
      ),
      if (belfioreStr.isNotEmpty)
        (effectiveL10n.cardBelfioreLabel, belfioreStr),
    ];

    var detailX = 56.0;
    for (final (label, val) in details) {
      _drawText(
        canvas: canvas,
        text: label,
        offset: Offset(detailX, 260),
        style: const TextStyle(
          color: AppColors.darkOnSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      );
      _drawText(
        canvas: canvas,
        text: val,
        offset: Offset(detailX, 282),
        style: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
      detailX += 260.0;
    }

    // 7. Optical Read Area (1D Barcode + 2D QR Code Container)
    final barcodeContainerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(56, 335, 1088, 305),
      const Radius.circular(20),
    );

    // White background for maximum optical contrast
    final opticalBgPaint = Paint()..color = AppColors.opticalWhite;
    canvas.drawRRect(barcodeContainerRect, opticalBgPaint);

    final opticalBorderPaint = Paint()
      ..color = AppColors.opticalBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(barcodeContainerRect, opticalBorderPaint);

    // 8. 1D Barcode (Code 128)
    final barcode128 = Barcode.code128();
    final barcode128Operations = barcode128.make(
      contact.taxCode,
      width: 700,
      height: 140,
    );

    final barcodePaint = Paint()..color = Colors.black;
    for (final element in barcode128Operations) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            96 + element.left,
            380 + element.top,
            element.width,
            element.height,
          ),
          barcodePaint,
        );
      }
    }

    _drawText(
      canvas: canvas,
      text: contact.taxCode,
      offset: const Offset(96, 545),
      style: AppTypography.codeDisplay(
        color: Colors.black87,
        letterSpacing: 4,
      ),
    );

    _drawText(
      canvas: canvas,
      text: effectiveL10n.barcodeCode128,
      offset: const Offset(96, 580),
      style: const TextStyle(
        color: AppColors.lightOnSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );

    // Vertical separator
    final dividerPaint = Paint()
      ..color = AppColors.opticalDivider
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(880, 360),
      const Offset(880, 615),
      dividerPaint,
    );

    // 9. 2D QR Code
    final qrCode = Barcode.qrCode();
    final qrOperations = qrCode.make(
      contact.taxCode,
      width: 170,
      height: 170,
    );

    for (final element in qrOperations) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            940 + element.left,
            380 + element.top,
            element.width,
            element.height,
          ),
          barcodePaint,
        );
      }
    }

    _drawText(
      canvas: canvas,
      text: effectiveL10n.cardQrCodeLabel,
      offset: const Offset(980, 580),
      style: const TextStyle(
        color: AppColors.lightOnSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );

    // 10. Bottom Footer
    final resolvedFooter = footerText ?? effectiveL10n.cardImageFooter;
    _drawText(
      canvas: canvas,
      text: resolvedFooter,
      offset: const Offset(56, 680),
      style: const TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 13,
      ),
    );
  }

  static void _drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    required TextStyle style,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }
}
