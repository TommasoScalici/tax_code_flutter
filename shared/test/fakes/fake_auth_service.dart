import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/services/auth_service.dart';

import 'fake_user.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  AuthStatus _status = AuthStatus.initializing;
  FakeUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _reauthShouldFail = false;
  bool simulateRequiresRecentLogin = false;

  @override
  AuthStatus get status => _status;

  @override
  FakeUser? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _status == AuthStatus.authenticated;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  /// Simulates a user logging in.
  void login(FakeUser user) {
    _currentUser = user;
    _errorMessage = null;
    _isLoading = false;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Simulates a user logging out.
  void logout() {
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Helper method for tests to simulate a loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Helper method for tests to simulate an error state.
  void setError(String? message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// This is very useful for testing the 'initializing' state.
  void setStatus(AuthStatus newStatus) {
    _status = newStatus;
    if (newStatus != AuthStatus.authenticated) {
      _currentUser = null;
    }
    notifyListeners();
  }

  void setReauthShouldFail(bool fail) {
    _reauthShouldFail = fail;
  }

  @override
  Future<void> deleteUserAccount() async {
    if (simulateRequiresRecentLogin) {
      simulateRequiresRecentLogin = false;
      throw FirebaseAuthException(code: 'requires-recent-login');
    }

    logout();
  }

  @override
  Future<void> signInWithGoogleForWearable() async {
    login(FakeUser(uid: 'fake-wear-uid'));
  }

  @override
  Future<void> signOut() async {
    logout();
  }

  @override
  Future<bool> reauthenticateWithGoogle() async {
    setLoading(true);

    await Future.delayed(const Duration(milliseconds: 100));

    if (_reauthShouldFail) {
      setError('Simulated re-auth failure');
      setLoading(false);
      _reauthShouldFail = false;
      return false;
    }

    setLoading(false);
    return true;
  }
}
