import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';

abstract class NativeViewServiceAbstract {
  Future<void> launchPhoneApp();
  Future<void> showContactList(List<Contact> contacts);
  Future<void> updateContactList(List<Contact> contacts);
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
    _logger.i('Invoking native phone app launcher.');
    try {
      await _platform.invokeMethod<String>('launchPhoneApp');
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
    _logger.i('Invoking native contact list update.');
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
}
