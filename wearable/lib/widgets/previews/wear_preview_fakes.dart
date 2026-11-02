import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

/// Centralized fake implementation of [NativeViewService] for Wear OS previews.
class FakeNativeViewService implements NativeViewService {
  const FakeNativeViewService();

  @override
  Future<void> launchPhoneApp() async {}

  @override
  Future<void> enableHighBrightnessMode() async {}

  @override
  Future<void> disableHighBrightnessMode() async {}
}

/// Centralized fake implementation of [ContactsListController] for Wear OS previews.
class FakeContactsListController extends ChangeNotifier
    implements ContactsListController {
  FakeContactsListController({
    List<Contact>? contacts,
    bool isLoading = false,
    bool isDemoMode = false,
    bool isLaunchingPhoneApp = false,
  }) : _contacts =
           contacts ??
           [
             TestContactFixtures.marioRossi,
             TestContactFixtures.lauraNeri,
             TestContactFixtures.giuseppeVerdi,
           ],
       _isLoading = isLoading,
       _isDemoMode = isDemoMode,
       _isLaunchingPhoneApp = isLaunchingPhoneApp;

  List<Contact> _contacts;
  bool _isLoading;
  bool _isDemoMode;
  bool _isLaunchingPhoneApp;

  @override
  List<Contact> get contacts => _contacts;

  @override
  bool get hasContacts => _isDemoMode || _contacts.isNotEmpty;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isDemoMode => _isDemoMode;

  @override
  bool get isLaunchingPhoneApp => _isLaunchingPhoneApp;

  void setContacts(List<Contact> contacts) {
    _contacts = contacts;
    notifyListeners();
  }

  void setLoading({required bool loading}) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDemoMode({required bool demoMode}) {
    _isDemoMode = demoMode;
    notifyListeners();
  }

  void setLaunchingPhoneApp({required bool launching}) {
    _isLaunchingPhoneApp = launching;
    notifyListeners();
  }

  @override
  void exitDemoMode() {
    _isDemoMode = false;
    notifyListeners();
  }

  @override
  Future<void> launchPhoneApp() async {
    _isLaunchingPhoneApp = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _isLaunchingPhoneApp = false;
    notifyListeners();
  }
}

/// Centralized fake implementation of [AuthService] for Wear OS previews.
class FakeWearAuthService extends ChangeNotifier implements AuthService {
  FakeWearAuthService({
    AuthStatus status = AuthStatus.authenticated,
    bool isLoading = false,
  }) : _status = status,
       _isLoading = isLoading;

  AuthStatus _status;
  bool _isLoading;

  @override
  AuthStatus get status => _status;

  @override
  bool get isSignedIn => _status == AuthStatus.authenticated;

  @override
  bool get isGuest => _status == AuthStatus.guest;

  @override
  bool get isLoading => _isLoading;

  @override
  User? get currentUser => null;

  @override
  AppFailure? get failure => null;

  @override
  String? get errorKey => null;

  @override
  String? get errorMessage => null;

  void setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void setLoading({required bool loading}) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> continueAsGuest() async {
    _status = AuthStatus.guest;
    notifyListeners();
  }

  @override
  Future<void> deleteUserAccount() async {}

  @override
  Future<bool> reauthenticateWithGoogle() async => true;

  @override
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  @override
  Future<void> signInWithGoogleForWearable() async {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
