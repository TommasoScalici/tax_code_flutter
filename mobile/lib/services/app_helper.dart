import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class AppHelper {
  static const _channel = MethodChannel('tommasoscalici.taxcode/channel');
  static final Logger _logger = Logger();

  static Future<void> openApp() async {
    try {
      await _channel.invokeMethod('openApp');
    } on PlatformException catch (e) {
      _logger.e('Error while trying to open the app: ${e.message}');
    } catch (e) {
      _logger.e('An unexpected error occurred: $e');
    }
  }
}
