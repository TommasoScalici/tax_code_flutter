import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
    final safeAreaPadding = MediaQuery.of(context).padding;

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
        Positioned(
          top: safeAreaPadding.top + 20,
          right: 20,
          child: IconButton(
            tooltip: l10n.tooltipToggleFlash,
            icon: Icon(
              controller.flashMode == FlashMode.off
                  ? Icons.flash_off
                  : Icons.flash_on,
              color: Colors.white,
              size: 30,
            ),
            onPressed: controller.toggleFlash,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: safeAreaPadding.bottom + 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  tooltip: isPictureTaken
                      ? l10n.tooltipConfirmPicture
                      : l10n.tooltipTakePicture,
                  onPressed: onMainButtonPressed,
                  child: Icon(
                    isPictureTaken ? Icons.check : Icons.camera_alt,
                  ),
                ),
                if (isPictureTaken)
                  FloatingActionButton(
                    tooltip: l10n.tooltipRetakePicture,
                    onPressed: controller.resetPicture,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.replay),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
