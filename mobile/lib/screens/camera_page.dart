import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/ocr_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';

/// This widget is responsible for creating and providing the CameraPageController
/// to the widget tree. It is clean of constructor dependencies.
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CameraPageController(
        ocrService: ctx.read<OCRServiceAbstract>(),
        logger: ctx.read<Logger>(),
        permissionService: ctx.read<PermissionServiceAbstract>(),
        cameraService: ctx.read<CameraServiceAbstract>(),
      )..initialize(),
      child: const _CameraView(),
    );
  }
}

/// This widget is responsible for building the UI and listening to the controller.
class _CameraView extends StatelessWidget {
  const _CameraView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraPageController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.takePicture)),
      backgroundColor: Colors.black,
      body: _buildBody(context, controller, l10n),
    );
  }

  /// Handles the logic for the main action button (take/confirm picture).
  Future<void> _onMainButtonPressed(
    BuildContext context,
    CameraPageController controller,
    AppLocalizations l10n,
  ) async {
    if (controller.status == CameraStatus.readyToScan) {
      await controller.takePicture();
    } else if (controller.status == CameraStatus.pictureTaken) {
      final contact = await controller.confirmAndProcessPicture();

      if (!context.mounted) return;

      if (contact != null) {
        Navigator.pop(context, contact);
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.ocrFailedErrorMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
      }
    }
  }

  /// Builds the main body of the widget based on the controller's status.
  Widget _buildBody(
    BuildContext context,
    CameraPageController controller,
    AppLocalizations l10n,
  ) {
    switch (controller.status) {
      case CameraStatus.initializing:
        return const Center(child: CircularProgressIndicator());

      case CameraStatus.permissionDenied:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_photography,
                  size: 50,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.cameraPermissionInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: Text(l10n.openSettings),
                  onPressed: controller.openAppSettingsHandler,
                ),
              ],
            ),
          ),
        );

      case CameraStatus.error:
        return Center(child: Text(l10n.genericError));

      case CameraStatus.readyToScan:
      case CameraStatus.pictureTaken:
      case CameraStatus.processingOCR:
        return _buildCameraView(context, controller, l10n);
    }
  }

  /// Builds the camera preview or the captured image with action buttons.
  Widget _buildCameraView(
    BuildContext context,
    CameraPageController controller,
    AppLocalizations l10n,
  ) {
    final isPictureTaken =
        controller.status == CameraStatus.pictureTaken ||
        controller.status == CameraStatus.processingOCR;

    final isProcessing = controller.status == CameraStatus.processingOCR;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (controller.cameraController != null &&
            controller.cameraController!.value.isInitialized)
          isPictureTaken
              ? RotatedBox(
                  quarterTurns: controller.quarterTurns,
                  child: Image.file(
                    File(controller.imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : CameraPreview(controller.cameraController!),
        if (!isProcessing)
          Positioned(
            top: 20,
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
        if (!isProcessing)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    tooltip: isPictureTaken
                        ? l10n.tooltipConfirmPicture
                        : l10n.tooltipTakePicture,
                    onPressed: () =>
                        _onMainButtonPressed(context, controller, l10n),
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
        if (isProcessing)
          const Stack(
            alignment: Alignment.center,
            children: [
              ModalBarrier(dismissible: false, color: Colors.black54),
              CircularProgressIndicator(),
            ],
          ),
      ],
    );
  }
}
