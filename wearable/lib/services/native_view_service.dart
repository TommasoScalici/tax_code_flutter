import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';

abstract class NativeViewServiceAbstract {
  Future<void> launchPhoneApp();
  Future<void> closeContactList();
  Future<void> showContactList(List<Contact> contacts);
  Future<void> updateContactList(List<Contact> contacts);
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
      throw e.message ?? 'Failed to launch app on phone.';
    }
  }

  @override
  Future<void> closeContactList() async {
    try {
      await _platform.invokeMethod<void>('closeNativeContactList');
    } on PlatformException catch (e, s) {
      _logger.e(
        "Failed to invoke native closeContactList: '${e.message}'.",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> showContactList(List<Contact> contacts) async {
    try {
      final contactsData = contacts.map((c) => c.toNativeMap()).toList();
      await _platform.invokeMethod('openNativeContactList', {
        'contacts': contactsData,
      });
    } on PlatformException catch (e, s) {
      _logger.e(
        'Failed to invoke native method: "${e.message}".',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateContactList(List<Contact> contacts) async {
    try {
      final contactsData = contacts.map((c) => c.toNativeMap()).toList();
      await _platform.invokeMethod('updateContactList', {
        'contacts': contactsData,
      });
    } on PlatformException catch (e, s) {
      _logger.e(
        'Failed to invoke native method: "${e.message}".',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  ///
  /// Enables the high brightness mode on the native side.
  ///
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

  ///
  /// Disables the high brightness mode on the native side.
  ///
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
