import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

class CameraPreviewOverlay extends StatelessWidget {
  const CameraPreviewOverlay({super.key});

  /// Standard ISO/IEC 7810 ID-1 aspect ratio (85.60 mm x 53.98 mm).
  static const double cardAspectRatio = 85.60 / 53.98;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraPageController>();
    final isPictureTaken =
        controller.status == CameraStatus.pictureTaken ||
        controller.status == CameraStatus.processing;

    final isProcessing = controller.status == CameraStatus.processing;

    if (controller.cameraController == null ||
        !controller.cameraController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);

    // Calculate responsive ID-1 card bounding box
    final cardWidth = math.min(size.width * 0.88, 380.0);
    final cardHeight = cardWidth / cardAspectRatio;
    final cardLeft = (size.width - cardWidth) / 2;
    // Offset slightly above vertical center to allow room for bottom controls
    final cardTop = ((size.height - cardHeight) / 2) - 36.0;
    final cardRect = Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera live feed or captured snapshot with matching BoxFit.cover
        if (isPictureTaken && controller.imagePath != null)
          RotatedBox(
            quarterTurns: controller.quarterTurns,
            child: Image.file(
              File(controller.imagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cameraController = controller.cameraController!;
              var cameraAspectRatio = cameraController.value.aspectRatio;
              if (cameraAspectRatio < 1) {
                cameraAspectRatio = 1 / cameraAspectRatio;
              }
              final previewRatio = 1 / cameraAspectRatio;

              return ClipRect(
                child: SizedOverflowBox(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth / previewRatio,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                ),
              );
            },
          ),

        // ID-1 Card framing guide cutout and corners
        CustomPaint(
          size: Size(size.width, size.height),
          painter: CardCutoutOverlayPainter(
            scrimColor: Colors.black.withValues(alpha: 0.58),
            guideColor: colorScheme.primary,
            outlineColor: AppColors.emeraldBorder,
            cardRect: cardRect,
          ),
        ),

        // Guidance pill badge above the card framing
        Positioned(
          top: math.max(16.0, cardRect.top - 54.0),
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.82,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.cameraCardGuideHint,
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Processing overlay
        if (isProcessing)
          Stack(
            alignment: Alignment.center,
            children: [
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: 0.65),
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ],
          ),
      ],
    );
  }
}

/// Custom painter that renders a dark scrim with an ID-1 rounded card cutout
/// and glowing guide brackets at each corner.
class CardCutoutOverlayPainter extends CustomPainter {
  final Color scrimColor;
  final Color guideColor;
  final Color outlineColor;
  final Rect cardRect;

  CardCutoutOverlayPainter({
    required this.scrimColor,
    required this.guideColor,
    required this.outlineColor,
    required this.cardRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    const radiusVal = 16.0;
    final cutoutRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(radiusVal),
    );

    final cutoutPath = Path()..addRRect(cutoutRRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Scrim overlay
    final scrimPaint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, scrimPaint);

    // Card boundary outline
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(cutoutRRect, outlinePaint);

    // Precision corner guides
    final cornerPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;

    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(cardRect.left, cardRect.top + cornerLength)
        ..lineTo(cardRect.left, cardRect.top + radiusVal)
        ..arcToPoint(
          Offset(cardRect.left + radiusVal, cardRect.top),
          radius: const Radius.circular(radiusVal),
        )
        ..lineTo(cardRect.left + cornerLength, cardRect.top),
      cornerPaint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(cardRect.right - cornerLength, cardRect.top)
        ..lineTo(cardRect.right - radiusVal, cardRect.top)
        ..arcToPoint(
          Offset(cardRect.right, cardRect.top + radiusVal),
          radius: const Radius.circular(radiusVal),
        )
        ..lineTo(cardRect.right, cardRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(cardRect.left, cardRect.bottom - cornerLength)
        ..lineTo(cardRect.left, cardRect.bottom - radiusVal)
        ..arcToPoint(
          Offset(cardRect.left + radiusVal, cardRect.bottom),
          radius: const Radius.circular(radiusVal),
        )
        ..lineTo(cardRect.left + cornerLength, cardRect.bottom),
      cornerPaint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(cardRect.right - cornerLength, cardRect.bottom)
        ..lineTo(cardRect.right - radiusVal, cardRect.bottom)
        ..arcToPoint(
          Offset(cardRect.right, cardRect.bottom - radiusVal),
          radius: const Radius.circular(radiusVal),
        )
        ..lineTo(cardRect.right, cardRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CardCutoutOverlayPainter oldDelegate) {
    return oldDelegate.scrimColor != scrimColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.cardRect != cardRect;
  }
}
