import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/gemini_service.dart';

import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';
import 'package:tax_code_flutter/widgets/camera/camera_controls_widget.dart';
import 'package:tax_code_flutter/widgets/camera/camera_preview_overlay.dart';

/// This widget is responsible for creating and providing the CameraPageController
/// to the widget tree. It is clean of constructor dependencies.
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CameraPageController(
        cameraService: ctx.read<CameraServiceAbstract>(),
        geminiService: ctx.read<GeminiServiceAbstract>(),
        permissionService: ctx.read<PermissionServiceAbstract>(),
        logger: ctx.read<Logger>(),
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
      final scannedData = await controller.confirmAndProcessPicture();

      if (!context.mounted) return;

      if (scannedData != null) {
        Navigator.pop(context, scannedData);
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.scanFailedErrorMessage),
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
        return const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        );

      case CameraStatus.permissionDenied:
        return SafeArea(
          child: Center(
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
          ),
        );

      case CameraStatus.error:
        return SafeArea(child: Center(child: Text(l10n.genericError)));

      case CameraStatus.readyToScan:
      case CameraStatus.pictureTaken:
      case CameraStatus.processing:
        return _buildCameraView(context, controller, l10n);
    }
  }

  /// Builds the camera preview or the captured image with action buttons.
  Widget _buildCameraView(
    BuildContext context,
    CameraPageController controller,
    AppLocalizations l10n,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const CameraPreviewOverlay(),
        CameraControlsWidget(
          onMainButtonPressed: () => _onMainButtonPressed(context, controller, l10n),
        ),
      ],
    );
  }
}
