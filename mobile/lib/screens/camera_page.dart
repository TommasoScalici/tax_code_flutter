// lib/screens/camera_page.dart

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/services/ocr_service.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

class CameraPage extends StatelessWidget {
  final OCRService ocrService;
  final Logger logger;

  const CameraPage({
    super.key,
    required this.ocrService,
    required this.logger,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraPageController(
        ocrService: ocrService,
        logger: logger,
      )..initialize(),
      child: const _CameraView(),
    );
  }
}

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
                const Icon(Icons.no_photography, size: 50, color: Colors.white70),
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
        return _buildCameraView(context, controller, l10n);
    }
  }

  Widget _buildCameraView(
    BuildContext context,
    CameraPageController controller,
    AppLocalizations l10n,
  ) {
    final isPictureTaken = controller.status == CameraStatus.pictureTaken;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (controller.cameraController != null && controller.cameraController!.value.isInitialized)
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
        
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            // ✅ Aggiunto Tooltip
            tooltip: l10n.tooltipToggleFlash,
            icon: Icon(
              controller.flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
              size: 30,
            ),
            onPressed: controller.toggleFlash,
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  tooltip: isPictureTaken ? l10n.tooltipConfirmPicture : l10n.tooltipTakePicture,
                  onPressed: () async {
                    if (isPictureTaken) {
                      final contact = await controller.performOcr();
                      if (context.mounted) Navigator.pop(context, contact);
                    } else {
                      await controller.takePicture();
                    }
                  },
                  child: Icon(isPictureTaken ? Icons.check : Icons.camera_alt),
                ),
                if (isPictureTaken)
                  FloatingActionButton(
                    // ✅ Aggiunto Tooltip
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