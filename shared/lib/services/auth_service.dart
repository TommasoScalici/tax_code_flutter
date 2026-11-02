import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/app_failure.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:shared/models/app_failure.dart';

enum AuthStatus { initializing, authenticated, guest, unauthenticated }

///
/// Manages the application's authentication state and actions.
/// Supports Google SSO authentication and a pure local-only Guest mode.
///
class AuthService with ChangeNotifier {
  static const String guestModePrefKey = 'auth_is_guest_mode';

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseService _dbService;
  final Logger _logger;
  final SharedPreferencesAsync _prefs;

  AuthStatus _status = AuthStatus.initializing;
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  AppFailure? _failure;
  bool _isLoading = false;

  /// The current authentication status.
  AuthStatus get status => _status;

  /// The currently signed-in user, or null if none or if in guest mode.
  User? get currentUser => _currentUser;

  /// Returns true if a user is currently signed in via Google SSO.
  bool get isSignedIn => _status == AuthStatus.authenticated;

  /// Returns true if the app is currently running in local offline guest mode.
  bool get isGuest => _status == AuthStatus.guest;

  /// Returns true if an authentication operation is in progress.
  bool get isLoading => _isLoading;

  /// Strongly typed failure representing the last error encountered during authentication operations.
  AppFailure? get failure => _failure;

  /// Semantic error key for localized UI presentation (e.g. 'networkError', 'signInFailed', 'reauthFailed').
  String? get errorKey => _failure?.toKey();

  /// An error message resulting from a failed authentication attempt, or null.
  /// Maintained for backwards compatibility.
  String? get errorMessage => errorKey;

  ///
  /// The main constructor for the authentication service.
  ///
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required DatabaseService dbService,
    required Logger logger,
    SharedPreferencesAsync? prefs,
  }) : _auth = auth,
       _googleSignIn = googleSignIn,
       _dbService = dbService,
       _logger = logger,
       _prefs = prefs ?? SharedPreferencesAsync() {
    unawaited(_initAuthState());
  }

  Future<void> _initAuthState() async {
    final isGuest = await _prefs.getBool(guestModePrefKey) ?? false;
    final user = _auth.currentUser;

    if (user != null) {
      if (user.isAnonymous) {
        _logger.i('Migrating legacy anonymous user to pure guest mode.');
        try {
          await _auth.signOut();
        } on Object catch (_) {}
        await _prefs.setBool(guestModePrefKey, true);
        _currentUser = null;
        _status = AuthStatus.guest;
      } else {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _validateAndSyncUserInBackground(user);
      }
    } else if (isGuest) {
      _currentUser = null;
      _status = AuthStatus.guest;
    } else {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }

    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  ///
  /// Continues in pure offline guest mode without contacting Firebase Auth.
  ///
  Future<void> continueAsGuest() async {
    _setLoading(true);
    try {
      if (_auth.currentUser != null) {
        try {
          await _auth.signOut();
        } on Object catch (_) {}
      }
      await _prefs.setBool(guestModePrefKey, true);
      _currentUser = null;
      _status = AuthStatus.guest;
      _failure = null;
      _logger.i('User continued in pure guest mode (offline).');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Delete the current user's account and their associated data.
  ///
  Future<void> deleteUserAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final uid = currentUser.uid;
      await _dbService.deleteAllUserData(uid);
      await currentUser.delete();
      await _prefs.setBool(guestModePrefKey, false);
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      _logger.i('User account and all associated data deleted successfully.');
    } catch (e, s) {
      _logger.e('Error deleting user account', error: e, stackTrace: s);
      rethrow;
    }
  }

  ///
  /// Re-authenticates the current user with Google.
  /// This is needed for sensitive operations like account deletion.
  ///
  Future<bool> reauthenticateWithGoogle() async {
    _setLoading(true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google Re-authentication was cancelled by the user.');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('User is null, cannot re-authenticate.');
        return false;
      }

      await user.reauthenticateWithCredential(credential);
      _logger.i('User re-authenticated successfully.');
      return true;
    } on FirebaseAuthException catch (e, s) {
      _logger.e(
        'Error during Google Re-authentication: ${e.code}',
        error: e,
        stackTrace: s,
      );
      _failure = e.code == 'network-request-failed'
          ? const NetworkFailure()
          : const ReauthFailedFailure();
      return false;
    } on Exception catch (e, s) {
      _logger.e(
        'Error during Google Re-authentication',
        error: e,
        stackTrace: s,
      );
      _failure = const ReauthFailedFailure();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Handles Google Sign-In and Firebase authentication.
  /// Returns true if sign-in succeeded, false if cancelled or failed.
  ///
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google Sign-In was cancelled by the user.');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _prefs.setBool(guestModePrefKey, false);
      _currentUser = userCredential.user;
      _status = AuthStatus.authenticated;
      _failure = null;
      _logger.i('Google Sign-In succeeded.');
      return true;
    } on FirebaseAuthException catch (e, s) {
      _logger.e(
        'Error during Google Sign-In: ${e.code}',
        error: e,
        stackTrace: s,
      );
      _failure = e.code == 'network-request-failed'
          ? const NetworkFailure()
          : const SignInFailedFailure();
      return false;
    } on Exception catch (e, s) {
      _logger.e('Error during Google Sign-In', error: e, stackTrace: s);
      _failure = const SignInFailedFailure();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Handles Google Sign-In for the Wearable app.
  ///
  Future<void> signInWithGoogleForWearable() async {
    await signInWithGoogle();
  }

  ///
  /// Signs the current user out from Firebase and Google.
  /// Clears persistent guest mode state.
  ///
  Future<void> signOut() async {
    _setLoading(true);
    try {
      try {
        await _googleSignIn.signOut();
      } on Object catch (e, s) {
        _logger.e('Error during Google sign out', error: e, stackTrace: s);
      }

      try {
        await _auth.signOut();
      } on Object catch (e, s) {
        _logger.e('Error during Firebase sign out', error: e, stackTrace: s);
      }

      await _prefs.setBool(guestModePrefKey, false);
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _failure = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Listens to authentication state changes from Firebase.
  ///
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      final isGuest = await _prefs.getBool(guestModePrefKey) ?? false;
      _currentUser = null;
      _status = isGuest ? AuthStatus.guest : AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (user.isAnonymous) {
      return;
    }

    _currentUser = user;
    _status = AuthStatus.authenticated;
    await _prefs.setBool(guestModePrefKey, false);
    notifyListeners();

    _validateAndSyncUserInBackground(user);
  }

  void _validateAndSyncUserInBackground(User user) {
    scheduleMicrotask(() async {
      try {
        _logger.i('Background: validating user with server...');
        await user.reload();

        final freshUser = _auth.currentUser;
        if (freshUser == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User disappeared after reload.',
          );
        }

        _currentUser = freshUser;

        if (!freshUser.isAnonymous) {
          try {
            await _dbService.saveUserData(freshUser);
          } on Object catch (dbErr, dbStack) {
            _logger.e(
              'Background: failed to save user data to Firestore',
              error: dbErr,
              stackTrace: dbStack,
            );
          }
        }

        _logger.i('Background: User validation successful.');
        notifyListeners();
      } on FirebaseAuthException catch (e, s) {
        final isAccountRemoved =
            e.code == 'user-not-found' || e.code == 'user-disabled';
        if (isAccountRemoved) {
          _logger.w(
            'Background: User account disabled or deleted. Forcing sign out.',
            error: e,
            stackTrace: s,
          );
          _currentUser = null;
          _status = AuthStatus.unauthenticated;
          await _prefs.setBool(guestModePrefKey, false);
          try {
            await _auth.signOut();
          } on Object catch (_) {}
          notifyListeners();
        } else {
          _logger.w(
            'Background: Server validation failed with non-fatal code (${e.code}). Keeping session.',
            error: e,
            stackTrace: s,
          );
        }
      } on Object catch (e, s) {
        _logger.w(
          'Background: Non-fatal error during user validation. Keeping session.',
          error: e,
          stackTrace: s,
        );
      }
    });
  }

  ///
  /// Private helper to manage the loading state and notify listeners.
  ///
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;

    _isLoading = loading;
    if (loading) {
      _failure = null;
    }

    notifyListeners();
  }
}
