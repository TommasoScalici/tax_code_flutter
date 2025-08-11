import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared/services/database_service.dart';

///
/// Manages the application's authentication state.
///
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  final DatabaseService _dbService;
  final Logger _logger;

  StreamSubscription? _authSubscription;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  ///
  /// The main constructor for the authentication service.
  ///
  AuthService({
    required FirebaseAuth auth,
    required DatabaseService dbService,
    required Logger logger,
  }) : _auth = auth,
       _dbService = dbService,
       _logger = logger {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _saveUserData(user);
    }
    notifyListeners();
  }

  ///
  /// Signs the current user out.
  ///
  Future<void> signOut() async {
    await _auth.signOut();
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
}
