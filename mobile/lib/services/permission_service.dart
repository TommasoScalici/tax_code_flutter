import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionServiceAbstract {
  Future<bool> requestCameraPermission();
  Future<bool> openAppSettingsHandler();
}

class PermissionService implements PermissionServiceAbstract {
  final Logger _logger;

  PermissionService({required Logger logger}) : _logger = logger;

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e, s) {
      _logger.e('Failed to request camera permission', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<bool> openAppSettingsHandler() async {
    try {
      return await openAppSettings();
    } catch (e, s) {
      _logger.e('Failed to open app settings', error: e, stackTrace: s);
      return false;
    }
  }
}