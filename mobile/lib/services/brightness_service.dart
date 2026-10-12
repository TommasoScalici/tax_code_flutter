import 'package:logger/logger.dart';
import 'package:screen_brightness/screen_brightness.dart';

abstract interface class BrightnessService {
  Future<void> setMaxBrightness();
  Future<void> resetBrightness();

  factory BrightnessService({required Logger logger}) = DefaultBrightnessService;
}

typedef BrightnessServiceAbstract = BrightnessService;

class DefaultBrightnessService implements BrightnessService {
  final Logger _logger;

  DefaultBrightnessService({required Logger logger}) : _logger = logger;

  @override
  Future<void> setMaxBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } on Object catch (e, s) {
      _logger.e('Failed to set max brightness', error: e, stackTrace: s);
    }
  }

  @override
  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } on Object catch (e, s) {
      _logger.e('Failed to reset brightness', error: e, stackTrace: s);
    }
  }
}