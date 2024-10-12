import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  var _flashMode = FlashMode.off;
  var _isInitialized = false;

  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  late CameraDescription camera;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    var permissionGranted = await requestCameraPermission();

    if (!permissionGranted && mounted) {
      Navigator.pop(context);
      return;
    }

    cameras = await availableCameras();
    camera = cameras.first;
    _cameraController = CameraController(camera, ResolutionPreset.high);
    await _cameraController.initialize();
    _isInitialized = true;
    setState(() {});
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (!status.isGranted || status.isDenied) {
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog();
      }

      status = await Permission.camera.request();

      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  Future<void> _showPermissionDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.permissionRequired),
          content: Text(AppLocalizations.of(context)!.cameraPermissionInfo),
          actions: [
            TextButton(
              onPressed: () async {
                var appSettingsOpened = await openAppSettings();

                if (context.mounted) {
                  if (!appSettingsOpened) {
                    context
                        .read<AppState>()
                        .logger
                        .e('Could not open app settings.');
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.openSettings),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      );

  Future<String?> _takePicture() async {
    try {
      final image = await _cameraController.takePicture();
      File imageFile = File(image.path);
      String base64Image = base64Encode(imageFile.readAsBytesSync());
      return base64Image;
    } catch (e) {
      if (mounted) {
        context.read<AppState>().logger.e('Error taking picture: $e');
      }
    }
    return null;
  }

  Future<void> _toggleFlash() async {
    if (_flashMode == FlashMode.off) {
      _flashMode = FlashMode.torch;
    } else {
      _flashMode = FlashMode.off;
    }

    await _cameraController.setFlashMode(_flashMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.takePicture)),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(
                _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final base64Image = await _takePicture();
          if (context.mounted) Navigator.pop(context, base64Image);
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
