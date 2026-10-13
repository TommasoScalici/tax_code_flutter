import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/testing/fake_user.dart';
import 'package:shared/utils/error_mapper.dart';

/// Centralized, full-featured fake implementation of [AuthService]
/// suitable for both unit tests and UI previews.
class FakeAuthService extends ChangeNotifier implements AuthService {
  AuthStatus _status;
  FakeUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _reauthShouldFail = false;
  bool simulateRequiresRecentLogin = false;

  /// Creates a [FakeAuthService] with customizable initial state.
  FakeAuthService({
    AuthStatus initialStatus = AuthStatus.initializing,
    FakeUser? initialUser,
    bool isGuest = false,
  }) : _status = initialStatus,
       _currentUser =
           initialUser ??
           (initialStatus == AuthStatus.authenticated
               ? FakeUser(
                   uid: isGuest ? 'fake-guest-uid' : 'fake-user-uid',
                   isAnonymous: isGuest,
                   displayName: isGuest ? 'Guest User' : 'Mario Rossi',
                   email: isGuest ? null : 'mario.rossi@example.com',
                 )
               : null);

  /// Convenience factory for an already authenticated user.
  factory FakeAuthService.authenticated({FakeUser? user}) => FakeAuthService(
    initialStatus: AuthStatus.authenticated,
    initialUser: user,
  );

  /// Convenience factory for a guest authenticated user.
  factory FakeAuthService.guest() =>
      FakeAuthService(initialStatus: AuthStatus.authenticated, isGuest: true);

  /// Convenience factory for an unauthenticated state.
  factory FakeAuthService.unauthenticated() =>
      FakeAuthService(initialStatus: AuthStatus.unauthenticated);

  @override
  AuthStatus get status => _status;

  @override
  FakeUser? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _status == AuthStatus.authenticated;

  @override
  bool get isGuest => _currentUser != null && _currentUser!.isAnonymous;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String? get errorKey => _errorMessage;

  @override
  AppFailure? get failure =>
      _errorMessage != null ? ErrorMapper.fromKey(_errorMessage) : null;

  @override
  Future<bool> signInWithGoogle() async {
    login(
      FakeUser(
        uid: 'fake-google-uid',
        displayName: 'Mario Rossi',
        email: 'mario.rossi@example.com',
      ),
    );
    return true;
  }

  @override
  Future<bool> signInAnonymously() async {
    login(
      FakeUser(
        uid: 'fake-guest-uid',
        isAnonymous: true,
        displayName: 'Guest User',
      ),
    );
    return true;
  }

  @override
  Future<void> signInWithGoogleForWearable() async {
    login(
      FakeUser(
        uid: 'fake-wear-uid',
        displayName: 'Wear User',
        email: 'wear.user@example.com',
      ),
    );
  }

  @override
  Future<void> signOut() async {
    logout();
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
  Future<bool> reauthenticateWithGoogle() async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (_reauthShouldFail) {
      setError('Simulated re-auth failure');
      setLoading(false);
      _reauthShouldFail = false;
      return false;
    }

    setLoading(false);
    return true;
  }

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

  /// Toggles whether the active user is in guest mode.
  void setGuest(bool isGuest) {
    if (isGuest) {
      _currentUser = FakeUser(
        uid: 'fake-guest-uid',
        isAnonymous: true,
        displayName: 'Guest User',
      );
      _status = AuthStatus.authenticated;
    } else {
      _currentUser = FakeUser(
        uid: 'fake-google-uid',
        displayName: 'Mario Rossi',
        email: 'mario.rossi@example.com',
      );
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  /// Toggles signed-in status directly.
  void setSignedIn(bool signedIn) {
    if (signedIn) {
      _currentUser ??= FakeUser(
        uid: 'fake-user-uid',
        displayName: 'Mario Rossi',
        email: 'mario.rossi@example.com',
      );
      _status = AuthStatus.authenticated;
    } else {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }
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

  /// Sets the authentication status explicitly.
  void setStatus(AuthStatus newStatus) {
    _status = newStatus;
    if (newStatus != AuthStatus.authenticated) {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Sets whether reauthentication should fail.
  void setReauthShouldFail(bool fail) {
    _reauthShouldFail = fail;
  }
}
