import 'package:logger/logger.dart';
import 'package:screen_brightness/screen_brightness.dart';

abstract class BrightnessServiceAbstract {
  Future<void> setMaxBrightness();
  Future<void> resetBrightness();
}

class BrightnessService implements BrightnessServiceAbstract {
  final Logger _logger;

  BrightnessService({required Logger logger}) : _logger = logger;

  @override
  Future<void> setMaxBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e, s) {
      _logger.e('Failed to set max brightness', error: e, stackTrace: s);
    }
  }

  @override
  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } catch (e, s) {
      _logger.e('Failed to reset brightness', error: e, stackTrace: s);
    }
  }
}