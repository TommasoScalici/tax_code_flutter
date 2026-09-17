import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class ContactsListController with ChangeNotifier {
  final ContactRepository _contactRepository;
  final NativeViewServiceAbstract _nativeViewService;
  final Logger _logger;

  bool _isLaunchingPhoneApp = false;

  bool get isLaunchingPhoneApp => _isLaunchingPhoneApp;
  bool get isLoading => _contactRepository.isLoading;
  bool get hasContacts => _contactRepository.contacts.isNotEmpty;
  List<Contact> get contacts => _contactRepository.contacts;

  ContactsListController({
    required ContactRepository contactRepository,
    required NativeViewServiceAbstract nativeViewService,
    required Logger logger,
  }) : _contactRepository = contactRepository,
       _nativeViewService = nativeViewService,
       _logger = logger {
    _contactRepository.addListener(_onContactsChanged);
  }

  @override
  void dispose() {
    _contactRepository.removeListener(_onContactsChanged);
    super.dispose();
  }

  /// Handles the action of launching the companion app on the phone,
  /// updating the loading state for the UI.
  Future<void> launchPhoneApp() async {
    _isLaunchingPhoneApp = true;
    notifyListeners();

    try {
      await _nativeViewService.launchPhoneApp();
    } on Object catch (e, s) {
      _logger.e('Error launching phone app', error: e, stackTrace: s);
    } finally {
      _isLaunchingPhoneApp = false;
      notifyListeners();
    }
  }

  void _onContactsChanged() {
    notifyListeners();
  }
}
