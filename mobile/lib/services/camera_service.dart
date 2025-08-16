import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

/// Defines the contract for a service that interacts with camera hardware.
abstract class CameraServiceAbstract {
  Future<List<CameraDescription>> getAvailableCameras();
}

/// The concrete implementation of [CameraServiceAbstract] using the
/// camera package.
class CameraService implements CameraServiceAbstract {
  final Logger _logger;

  CameraService({required Logger logger}) : _logger = logger;
  
  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e, s) {
      _logger.e('Failed to get available cameras', error: e, stackTrace: s);
      return [];
    }
  }
}