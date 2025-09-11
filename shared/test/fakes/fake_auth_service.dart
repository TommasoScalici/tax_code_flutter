import 'package:flutter/foundation.dart';
import 'package:shared/services/auth_service.dart';

import 'fake_user.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  FakeUser? _currentUser;
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  FakeUser? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  /// Simulates a user logging in.
  void login(FakeUser user) {
    _currentUser = user;
    _isSignedIn = true;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Simulates a user logging out.
  void logout() {
    _currentUser = null;
    _isSignedIn = false;
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

  @override
  Future<void> deleteUserAccount() async {}

  @override
  Future<void> signInWithGoogleForWearable() async {}

  @override
  Future<void> signOut() async {
    logout();
  }
}
