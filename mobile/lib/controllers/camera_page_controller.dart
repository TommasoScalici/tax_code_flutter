import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/gemini_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';

enum CameraStatus {
  initializing,
  permissionDenied,
  readyToScan,
  pictureTaken,
  processing,
  error,
}

class CameraPageController with ChangeNotifier {
  final CameraServiceAbstract _cameraService;
  final GeminiServiceAbstract _geminiService;
  final PermissionServiceAbstract _permissionService;
  final Logger _logger;

  CameraController? _cameraController;
  String? _imagePath;
  FlashMode _flashMode = FlashMode.off;
  DeviceOrientation? _pictureOrientation;
  CameraStatus _status = CameraStatus.initializing;

  CameraStatus get status => _status;
  CameraController? get cameraController => _cameraController;
  String? get imagePath => _imagePath;
  FlashMode get flashMode => _flashMode;

  CameraPageController({
    required CameraServiceAbstract cameraService,
    required GeminiServiceAbstract geminiService,
    required PermissionServiceAbstract permissionService,
    required Logger logger,
  }) : _cameraService = cameraService,
       _geminiService = geminiService,
       _permissionService = permissionService,
       _logger = logger;

  /// Initializes the camera and checks for permission.
  Future<void> initialize() async {
    final isGranted = await _permissionService.requestCameraPermission();
    if (!isGranted) {
      _updateStatus(CameraStatus.permissionDenied);
      return;
    }

    try {
      final cameras = await _cameraService.getAvailableCameras();
      if (cameras.isEmpty) throw Exception('No cameras found');

      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      _updateStatus(CameraStatus.readyToScan);
    } catch (e, s) {
      _logger.e('Error initializing camera', error: e, stackTrace: s);
      _updateStatus(CameraStatus.error);
    }
  }

  /// Processes the taken picture with the Gemini service and returns [ScannedData].
  Future<ScannedData?> confirmAndProcessPicture() async {
    if (status != CameraStatus.pictureTaken || imagePath == null) return null;

    _updateStatus(CameraStatus.processing);

    try {
      final imageBytes = await File(imagePath!).readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      final scannedData = await _geminiService.extractDataFromDocument(
        base64Image,
      );

      _updateStatus(CameraStatus.pictureTaken);

      return scannedData;
    } catch (e, s) {
      _logger.e('Gemini processing failed', error: e, stackTrace: s);
      _updateStatus(CameraStatus.pictureTaken);
      return null;
    }
  }

  /// Opens the app settings via the service.
  Future<void> openAppSettingsHandler() async {
    _logger.i('Opening app settings via service...');
    await _permissionService.openAppSettingsHandler();
  }

  /// Resets the picture and updates the status to [CameraStatus.readyToScan].
  Future<void> resetPicture() async {
    if (_cameraController == null) return;

    _imagePath = null;
    await _cameraController!.resumePreview();
    _updateStatus(CameraStatus.readyToScan);
  }

  /// Takes a picture and updates the status to [CameraStatus.pictureTaken].
  Future<void> takePicture() async {
    if (_cameraController == null || _status != CameraStatus.readyToScan) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      await _cameraController!.pausePreview();
      _pictureOrientation = _cameraController!.value.deviceOrientation;
      _imagePath = image.path;
      _updateStatus(CameraStatus.pictureTaken);
    } catch (e, s) {
      _logger.e('Error taking picture', error: e, stackTrace: s);
      _updateStatus(CameraStatus.error);
    }
  }

  /// Toggles the camera flash mode.
  Future<void> toggleFlash() async {
    if (_cameraController == null) return;

    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _cameraController!.setFlashMode(_flashMode);
    notifyListeners();
  }

  /// Returns the current quarter turn value based on the camera's orientation.
  int get quarterTurns {
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

  void _updateStatus(CameraStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.setFlashMode(FlashMode.off);
    _cameraController?.dispose();
    super.dispose();
  }
}
