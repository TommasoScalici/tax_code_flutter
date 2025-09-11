import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionHandlerAdapter {
  Future<PermissionStatus> requestCamera();
  Future<bool> openSettings();
}

class AppPermissionHandlerAdapter implements PermissionHandlerAdapter {
  @override
  Future<PermissionStatus> requestCamera() => Permission.camera.request();

  @override
  Future<bool> openSettings() => openAppSettings();
}

abstract class PermissionServiceAbstract {
  Future<bool> requestCameraPermission();
  Future<bool> openAppSettingsHandler();
}

class PermissionService implements PermissionServiceAbstract {
  final Logger _logger;
  final PermissionHandlerAdapter _permissionHandler;

  PermissionService({
    required Logger logger,
    required PermissionHandlerAdapter permissionHandler, // <-- INIETTATA QUI
  }) : _logger = logger,
       _permissionHandler = permissionHandler;

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final status = await _permissionHandler.requestCamera();
      return status.isGranted;
    } catch (e, s) {
      _logger.e('Failed to request camera permission', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<bool> openAppSettingsHandler() async {
    try {
      return await _permissionHandler.openSettings();
    } catch (e, s) {
      _logger.e('Failed to open app settings', error: e, stackTrace: s);
      return false;
    }
  }
}
