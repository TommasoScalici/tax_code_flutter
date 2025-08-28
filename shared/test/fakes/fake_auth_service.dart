import 'package:flutter/foundation.dart';
import 'package:shared/services/auth_service.dart';

import 'fake_user.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  FakeUser? _currentUser;
  bool _isSignedIn = false;

  @override
  FakeUser? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _isSignedIn;

  void login(FakeUser user) {
    _currentUser = user;
    _isSignedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isSignedIn = false;
    notifyListeners();
  }

  @override
  Future<void> deleteUserAccount() async {}
  @override
  Future<void> signInWithGoogleForWearable() async {}
  @override
  Future<void> signOut() async {}
  @override
  bool get isLoading => false;

  // TODO to check
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
