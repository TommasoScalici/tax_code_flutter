import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

abstract class NativeViewServiceAbstract {
  Future<void> launchPhoneApp();
  Future<void> enableHighBrightnessMode();
  Future<void> disableHighBrightnessMode();
}

class NativeViewService implements NativeViewServiceAbstract {
  final MethodChannel _platform;
  final Logger _logger;

  NativeViewService({required Logger logger, MethodChannel? platform})
    : _logger = logger,
      _platform =
          platform ??
          const MethodChannel(
            'tommasoscalici.tax_code_flutter_wear_os/channel',
          );

  @override
  Future<void> launchPhoneApp() async {
    try {
      await _platform.invokeMethod<bool>('launchPhoneApp');
    } on PlatformException catch (e, s) {
      _logger.e(
        "Failed to invoke native launchPhoneApp: '${e.message}'.",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Enables high brightness mode on the native display.
  @override
  Future<void> enableHighBrightnessMode() async {
    try {
      await _platform.invokeMethod<void>('enableHighBrightnessMode');
    } on PlatformException catch (e, s) {
      _logger.e(
        "Failed to invoke enableHighBrightnessMode: '${e.message}'.",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Disables high brightness mode on the native display.
  @override
  Future<void> disableHighBrightnessMode() async {
    try {
      await _platform.invokeMethod<void>('disableHighBrightnessMode');
    } on PlatformException catch (e, s) {
      _logger.e(
        "Failed to invoke disableHighBrightnessMode: '${e.message}'.",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
