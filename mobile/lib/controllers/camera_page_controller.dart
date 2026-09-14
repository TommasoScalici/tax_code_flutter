import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/services/gemini_service.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';

enum CameraStatus {
  initializing,
  permissionDenied,
  readyToScan,
  pictureTaken,
  processing,
  error,
}

typedef CameraControllerFactory =
    CameraController Function(
      CameraDescription description,
      ResolutionPreset preset, {
      bool enableAudio,
    });

typedef ImageProcessor = Future<String> Function(String filePath);

/// Resizes the image so neither dimension exceeds [maxDimension],
/// compresses it as JPEG with [quality], and encodes it to Base64 in a background isolate.
Future<String> defaultImageProcessor(
  String filePath, {
  int maxDimension = 1280,
  int quality = 80,
}) async {
  return Isolate.run(() {
    final rawBytes = File(filePath).readAsBytesSync();
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        return base64Encode(rawBytes);
      }

      img.Image processed = decoded;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width >= decoded.height) {
          processed = img.copyResize(decoded, width: maxDimension);
        } else {
          processed = img.copyResize(decoded, height: maxDimension);
        }
      }

      final compressedBytes = img.encodeJpg(processed, quality: quality);
      return base64Encode(compressedBytes);
    } on Object {
      return base64Encode(rawBytes);
    }
  });
}

class CameraPageController with ChangeNotifier, WidgetsBindingObserver {
  final CameraControllerFactory _cameraControllerFactory;
  final CameraServiceAbstract _cameraService;
  final GeminiServiceAbstract _geminiService;
  final PermissionServiceAbstract _permissionService;
  final ImageProcessor _imageProcessor;
  final Logger _logger;

  CameraController? _cameraController;
  String? _imagePath;
  FlashMode _flashMode = FlashMode.off;
  DeviceOrientation? _pictureOrientation;
  CameraStatus _status = CameraStatus.initializing;
  WidgetsBinding? _widgetsBinding;
  bool _isDisposed = false;
  bool _isObserverRegistered = false;

  CameraStatus get status => _status;
  CameraController? get cameraController => _cameraController;
  String? get imagePath => _imagePath;
  FlashMode get flashMode => _flashMode;

  CameraPageController({
    required CameraServiceAbstract cameraService,
    required GeminiServiceAbstract geminiService,
    required PermissionServiceAbstract permissionService,
    required Logger logger,
    CameraControllerFactory? cameraControllerFactory,
    ImageProcessor? imageProcessor,
    WidgetsBinding? widgetsBinding,
  }) : _cameraService = cameraService,
       _geminiService = geminiService,
       _permissionService = permissionService,
       _logger = logger,
       _cameraControllerFactory =
           cameraControllerFactory ?? CameraController.new,
       _imageProcessor = imageProcessor ?? defaultImageProcessor,
       _widgetsBinding = widgetsBinding;

  /// Initializes the camera and checks for permission.
  Future<void> initialize() async {
    _ensureLifecycleObserver();

    final isGranted = await _permissionService.requestCameraPermission();
    if (!isGranted) {
      _updateStatus(CameraStatus.permissionDenied);
      return;
    }

    try {
      final cameras = await _cameraService.getAvailableCameras();
      if (cameras.isEmpty) throw Exception('No cameras found');

      final camera = cameras.first;
      _cameraController = _cameraControllerFactory(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      _updateStatus(CameraStatus.readyToScan);
    } on Object catch (e, s) {
      _logger.e('Error initializing camera', error: e, stackTrace: s);
      _updateStatus(CameraStatus.error);
    }
  }

  /// Processes the taken picture with the Gemini service and returns [ScannedData].
  Future<ScannedData?> confirmAndProcessPicture() async {
    if (status != CameraStatus.pictureTaken || imagePath == null) return null;

    _updateStatus(CameraStatus.processing);

    try {
      final base64Image = await _imageProcessor(imagePath!);
      final scannedData = await _geminiService.extractDataFromDocument(
        base64Image,
      );

      _updateStatus(CameraStatus.pictureTaken);

      return scannedData;
    } on Object catch (e, s) {
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

    await _deleteTempImage();
    await _cameraController!.resumePreview();
    _updateStatus(CameraStatus.readyToScan);
  }

  /// Takes a picture and updates the status to [CameraStatus.pictureTaken].
  Future<void> takePicture() async {
    if (_cameraController == null || _status != CameraStatus.readyToScan) {
      return;
    }

    try {
      if (_imagePath != null) {
        await _deleteTempImage();
      }

      final image = await _cameraController!.takePicture();
      await _cameraController!.pausePreview();
      _pictureOrientation = _cameraController!.value.deviceOrientation;
      _imagePath = image.path;
      _updateStatus(CameraStatus.pictureTaken);
    } on Object catch (e, s) {
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
    switch (_pictureOrientation ?? DeviceOrientation.portraitUp) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeRight:
        return 1;
      case DeviceOrientation.portraitDown:
        return 2;
      case DeviceOrientation.landscapeLeft:
        return 3;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        unawaited(_onAppPaused());
      case AppLifecycleState.resumed:
        unawaited(_onAppResumed());
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onAppPaused() async {
    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      _cameraController = null;
      try {
        await controller.dispose();
      } on Object catch (e, s) {
        _logger.w('Error disposing camera on pause', error: e, stackTrace: s);
      }
      notifyListeners();
    }
  }

  Future<void> _onAppResumed() async {
    if (_isDisposed) return;
    if (_cameraController == null && _status != CameraStatus.permissionDenied) {
      await initialize();
    }
  }

  Future<void> _deleteTempImage() async {
    final path = _imagePath;
    _imagePath = null;
    if (path == null) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } on Object catch (e, s) {
      _logger.w(
        'Could not delete temporary camera file at $path',
        error: e,
        stackTrace: s,
      );
    }
  }

  void _ensureLifecycleObserver() {
    if (!_isObserverRegistered) {
      try {
        _widgetsBinding ??= WidgetsBinding.instance;
        _widgetsBinding?.addObserver(this);
        _isObserverRegistered = true;
      } on Object {
        // WidgetsBinding not initialized (e.g. running in unit test without binding)
      }
    }
  }

  void _updateStatus(CameraStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_isObserverRegistered && _widgetsBinding != null) {
      _widgetsBinding!.removeObserver(this);
      _isObserverRegistered = false;
    }
    final controller = _cameraController;
    if (controller != null) {
      unawaited(controller.setFlashMode(FlashMode.off));
      unawaited(controller.dispose());
      _cameraController = null;
    }
    unawaited(_deleteTempImage());
    super.dispose();
  }
}
