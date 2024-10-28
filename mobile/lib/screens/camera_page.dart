import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/services/ocr_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _logger = Logger();
  final _ocrService = OCRService();

  String? _base64Image;
  String? _imagePath;

  var _flashMode = FlashMode.off;
  var _isInitialized = false;
  var _isPictureTaken = false;

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  late CameraDescription _camera;
  late DeviceOrientation _pictureOrientation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _ocrService.initialize();
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

    _cameras = await availableCameras();
    _camera = _cameras.first;
    _cameraController =
        CameraController(_camera, ResolutionPreset.high, enableAudio: false);

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
                    _logger.e('Could not open app settings.');
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

  void _resetPicture() {
    setState(() {
      _base64Image = null;
      _isPictureTaken = false;
    });
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraController.takePicture();
      _pictureOrientation = _cameraController.value.deviceOrientation;
      _imagePath = image.path;
      File imageFile = File(image.path);
      var imageBytes = await imageFile.readAsBytes();
      _base64Image = base64Encode(imageBytes);

      setState(() {
        _isPictureTaken = true;
      });
    } catch (e) {
      if (mounted) {
        _logger.e('Error taking picture: $e');
      }
    }
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

  Future<Contact?> _performOcr() async {
    try {
      final ocrResult = await _ocrService.performCardOCR(_base64Image!);
      return ocrResult;
    } on Exception catch (e) {
      _logger.e('Error during OCR analysis: $e');
    }

    return null;
  }

  int _orientateImage() {
    switch (_pictureOrientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeRight:
        return 1;
      case DeviceOrientation.portraitDown:
        return 2;
      case DeviceOrientation.landscapeLeft:
        return 3;
      default:
        return 0;
    }
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
          _isPictureTaken && _imagePath != null
              ? RotatedBox(
                  quarterTurns: _orientateImage(),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : Center(child: CameraPreview(_cameraController)),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      if (_isPictureTaken && _base64Image != null) {
                        var contact = await _performOcr();
                        if (context.mounted) Navigator.pop(context, contact);
                      } else {
                        await _takePicture();
                        setState(() {
                          _isPictureTaken = true;
                        });
                      }
                    },
                    child: Icon(_isPictureTaken ? Icons.check : Icons.camera),
                  ),
                  if (_isPictureTaken)
                    FloatingActionButton(
                      onPressed: _resetPicture,
                      child: const Icon(Icons.replay),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
