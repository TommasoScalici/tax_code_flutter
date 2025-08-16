import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';

abstract class NativeViewServiceAbstract {
  Future<void> showContactList(List<Contact> contacts);
}

class NativeViewService implements NativeViewServiceAbstract {
  final MethodChannel _platform;
  final Logger _logger;

  NativeViewService({
    required Logger logger,
    MethodChannel? platform,
  }) : _logger = logger,
       _platform = platform ?? const MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  @override
  Future<void> showContactList(List<Contact> contacts) async {
    _logger.i('Invoking native contact list view.');
    try {
      final contactsData = contacts.map((c) => c.toNativeMap()).toList();
      await _platform.invokeMethod('openNativeContactList', {
        'contacts': contactsData,
      });
    } on PlatformException catch (e, s) {
      _logger.e("Failed to invoke native method: '${e.message}'.", error: e, stackTrace: s);
      rethrow;
    }
  }
}