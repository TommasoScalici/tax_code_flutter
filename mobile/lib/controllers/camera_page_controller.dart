import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tax_code_flutter/services/ocr_service.dart';
import 'package:shared/models/contact.dart';

enum CameraStatus {
  initializing,
  permissionDenied,
  readyToScan,
  pictureTaken,
  error,
}

class CameraPageController with ChangeNotifier {
  final OCRService _ocrService;
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
    required OCRService ocrService,
    required Logger logger,
  })  : _ocrService = ocrService,
        _logger = logger;

  Future<void> initialize() async {
    var permissionStatus = await Permission.camera.request();
    if (!permissionStatus.isGranted) {
      _updateStatus(CameraStatus.permissionDenied);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras found');
      
      final camera = cameras.first;
      _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
      await _cameraController!.initialize();
      
      _updateStatus(CameraStatus.readyToScan);
    } catch (e) {
      _logger.e('Error initializing camera: $e');
      _updateStatus(CameraStatus.error);
    }
  }

  Future<void> takePicture() async {
    if (_cameraController == null || _status != CameraStatus.readyToScan) return;
    
    try {
      final image = await _cameraController!.takePicture();
      _pictureOrientation = _cameraController!.value.deviceOrientation;
      _imagePath = image.path;
      _updateStatus(CameraStatus.pictureTaken);
    } catch (e) {
      _logger.e('Error taking picture: $e');
      _updateStatus(CameraStatus.error);
    }
  }

  void resetPicture() {
    _imagePath = null;
    _updateStatus(CameraStatus.readyToScan);
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null) return;
    
    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _cameraController!.setFlashMode(_flashMode);
    notifyListeners();
  }

  Future<Contact?> performOcr() async {
    if (_imagePath == null) return null;
    
    try {
      final imageBytes = await File(_imagePath!).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      return await _ocrService.performCardOCR(base64Image);
    } on Exception catch (e) {
      _logger.e('Error during OCR analysis: $e');
      return null;
    }
  }
  
  int get quarterTurns {
    switch (_pictureOrientation) {
      case DeviceOrientation.portraitUp: return 0;
      case DeviceOrientation.landscapeRight: return 1;
      case DeviceOrientation.portraitDown: return 2;
      case DeviceOrientation.landscapeLeft: return 3;
      default: return 0;
    }
  }

  void _updateStatus(CameraStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  Future<void> openAppSettingsHandler() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}