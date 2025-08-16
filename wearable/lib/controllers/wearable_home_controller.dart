import 'package:flutter/foundation.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class WearableHomeController with ChangeNotifier {
  final ContactRepository _contactRepository;
  final NativeViewServiceAbstract _nativeViewService;
  bool _nativeViewShown = false;

  WearableHomeController({
    required ContactRepository contactRepository,
    required NativeViewServiceAbstract nativeViewService,
  }) : _contactRepository = contactRepository,
       _nativeViewService = nativeViewService {
    _contactRepository.addListener(_onContactsChanged);
    _onContactsChanged();
  }

  void _onContactsChanged() {
    final contacts = _contactRepository.contacts;
    if (contacts.isNotEmpty && !_nativeViewShown) {
      _nativeViewShown = true;
      _nativeViewService.showContactList(contacts);
    } else if (contacts.isEmpty) {
      _nativeViewShown = false;
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _contactRepository.removeListener(_onContactsChanged);
    super.dispose();
  }
}