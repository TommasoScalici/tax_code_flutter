import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared/services/database_service.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

///
/// Manages the application's authentication state and actions.
///
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseService _dbService;
  final Logger _logger;

  AuthStatus _status = AuthStatus.initializing;
  StreamSubscription? _authSubscription;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  /// The current authentication status.
  AuthStatus get status => _status;

  /// The currently signed-in user, or null if none.
  User? get currentUser => _currentUser;

  /// Returns true if a user is currently signed in.
  bool get isSignedIn => _status == AuthStatus.authenticated;

  /// Returns true if an authentication operation is in progress.
  bool get isLoading => _isLoading;

  /// An error message resulting from a failed authentication attempt, or null.
  String? get errorMessage => _errorMessage;

  ///
  /// The main constructor for the authentication service.
  ///
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required DatabaseService dbService,
    required Logger logger,
  }) : _auth = auth,
       _googleSignIn = googleSignIn,
       _dbService = dbService,
       _logger = logger {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
    _errorMessage = null;

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
    } on Exception catch (e, s) {
      _logger.e(
        'Error during Google Re-authentication',
        error: e,
        stackTrace: s,
      );
      _errorMessage = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Handles the entire Google Sign-In and Firebase authentication process
  /// for the Wearable app.
  ///
  Future<void> signInWithGoogleForWearable() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google Sign-In was cancelled by the user.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on Exception catch (e, s) {
      _logger.e('Error during Google Sign-In', error: e, stackTrace: s);
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Signs the current user out from Firebase and Google. This method attempts
  /// both sign-outs and logs errors individually without stopping the process.
  ///
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, s) {
      _logger.e('Error during Google sign out', error: e, stackTrace: s);
    }

    try {
      await _auth.signOut();
    } catch (e, s) {
      _logger.e('Error during Firebase sign out', error: e, stackTrace: s);
    }
  }

  ///
  /// Listens to authentication state changes from Firebase.
  ///
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _logger.i('User detected, validating with server...');
      await user.reload();
      final freshUser = _auth.currentUser;
      if (freshUser == null) {
        throw Exception('User disappeared immediately after reload.');
      }

      _currentUser = freshUser;

      await _saveUserData(freshUser);

      _logger.i('User validation successful.');
      _status = AuthStatus.authenticated;
    } catch (e, s) {
      _logger.w(
        'User validation failed (reload or save). Assuming deleted/disabled. Forcing sign out.',
        error: e,
        stackTrace: s,
      );
      _currentUser = null;
      _status = AuthStatus.unauthenticated;

      await _auth.signOut();
    }

    notifyListeners();
  }

  ///
  /// Saves user metadata to Firestore upon login or registration.
  ///
  Future<void> _saveUserData(User user) async {
    try {
      await _dbService.saveUserData(user);
    } on Exception catch (e, s) {
      _logger.e('Error while storing user data', error: e, stackTrace: s);
      rethrow;
    }
  }

  ///
  /// Private helper to manage the loading state and notify listeners.
  ///
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;

    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }

    notifyListeners();
  }
}
