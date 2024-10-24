import 'package:flutter/services.dart';

class WearPhoneBridge {
  static const platform = MethodChannel('wear_os_bridge_controls');
  static final WearPhoneBridge _instance = WearPhoneBridge._internal();

  factory WearPhoneBridge() => _instance;

  WearPhoneBridge._internal();

  Future<bool> openOnPhone() async {
    try {
      final result = await platform.invokeMethod<bool>('openOnPhone');
      return result ?? false;
    } on PlatformException {
      rethrow;
    }
  }
}
