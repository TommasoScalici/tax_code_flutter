import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

/// Defines the contract for a service that interacts with camera hardware.
abstract interface class CameraService {
  Future<List<CameraDescription>> getAvailableCameras();

  factory CameraService({required Logger logger}) = DefaultCameraService;
}

typedef CameraServiceAbstract = CameraService;

/// The concrete default implementation of [CameraService] using the
/// camera package.
class DefaultCameraService implements CameraService {
  final Logger _logger;

  DefaultCameraService({required Logger logger}) : _logger = logger;

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } on Object catch (e, s) {
      _logger.e('Failed to get available cameras', error: e, stackTrace: s);
      return [];
    }
  }
}
