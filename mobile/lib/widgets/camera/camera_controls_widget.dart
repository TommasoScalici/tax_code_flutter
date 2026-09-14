import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

class CameraControlsWidget extends StatelessWidget {
  final Future<void> Function() onMainButtonPressed;

  const CameraControlsWidget({
    super.key,
    required this.onMainButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraPageController>();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final safeAreaPadding = MediaQuery.paddingOf(context);

    final isPictureTaken =
        controller.status == CameraStatus.pictureTaken ||
        controller.status == CameraStatus.processing;

    final isProcessing = controller.status == CameraStatus.processing;

    if (isProcessing) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Top action bar: Close button (left) and Flash toggle (right)
        Positioned(
          top: safeAreaPadding.top + 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.75,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
        Positioned(
          top: safeAreaPadding.top + 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.75,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: IconButton(
              tooltip: l10n.tooltipToggleFlash,
              icon: Icon(
                controller.flashMode == FlashMode.off
                    ? Icons.flash_off
                    : Icons.flash_on,
                color: controller.flashMode == FlashMode.off
                    ? colorScheme.onSurface
                    : colorScheme.primary,
                size: 24,
              ),
              onPressed: controller.toggleFlash,
            ),
          ),
        ),

        // Bottom camera controls
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: safeAreaPadding.bottom + 36.0),
            child: isPictureTaken
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Retake button (M3 error container)
                      FloatingActionButton(
                        heroTag: 'camera_retake_button',
                        tooltip: l10n.tooltipRetakePicture,
                        onPressed: controller.resetPicture,
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                        elevation: 2,
                        child: const Icon(Icons.replay, size: 28),
                      ),
                      const SizedBox(width: 48),
                      // Confirm button (M3 primary emerald)
                      FloatingActionButton.large(
                        heroTag: 'camera_confirm_button',
                        tooltip: l10n.tooltipConfirmPicture,
                        onPressed: onMainButtonPressed,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 4,
                        child: const Icon(Icons.check, size: 36),
                      ),
                    ],
                  )
                : FloatingActionButton.large(
                    heroTag: 'camera_capture_button',
                    tooltip: l10n.tooltipTakePicture,
                    onPressed: onMainButtonPressed,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 4,
                    child: const Icon(Icons.camera_alt, size: 36),
                  ),
          ),
        ),
      ],
    );
  }
}
