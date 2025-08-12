import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared/services/database_service.dart';

///
/// Manages the application's authentication state and actions.
///
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseService _dbService;
  final Logger _logger;

  StreamSubscription? _authSubscription;
  User? _currentUser;
  bool _isLoading = false;

  /// The currently signed-in user, or null if none.
  User? get currentUser => _currentUser;

  /// Returns true if a user is currently signed in.
  bool get isSignedIn => _currentUser != null;

  /// Returns true if an authentication operation is in progress.
  bool get isLoading => _isLoading;

  ///
  /// The main constructor for the authentication service.
  ///
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required DatabaseService dbService,
    required Logger logger,
  })  : _auth = auth,
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
  /// Handles the entire Google Sign-In and Firebase authentication process
  /// for the Wearable app.
  ///
  Future<void> signInWithGoogleForWearable() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google Sign-In was cancelled by the user.');
        _setLoading(false);
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
    } finally {
      _setLoading(false);
    }
  }

  ///
  /// Signs the current user out from Firebase and Google.
  ///
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on Exception catch (e, s) {
      _logger.e('Error during sign out', error: e, stackTrace: s);
    }
  }

  ///
  /// Listens to authentication state changes from Firebase.
  ///
  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _saveUserData(user);
    }

    if (_isLoading) {
      _isLoading = false;
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
    }
  }

  ///
  /// Private helper to manage the loading state and notify listeners.
  ///
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
}