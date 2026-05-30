import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';

class CameraPreviewOverlay extends StatelessWidget {
  const CameraPreviewOverlay({super.key});

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

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isPictureTaken)
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
          CameraPreview(controller.cameraController!),
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
