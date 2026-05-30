import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared/services/auth_service.dart';

class ProfileScreenController extends ChangeNotifier {
  final AuthService _authService;
  final Logger _logger;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorKey;
  String? get errorKey => _errorKey;

  String? _customErrorMessage;
  String? get customErrorMessage => _customErrorMessage;

  ProfileScreenController({
    required AuthService authService,
    required Logger logger,
  })  : _authService = authService,
        _logger = logger;

  void clearError() {
    _errorKey = null;
    _customErrorMessage = null;
    notifyListeners();
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      await _authService.signOut();
      return true;
    } catch (e, s) {
      _logger.e('Failed to sign out', error: e, stackTrace: s);
      _errorKey = 'genericError';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount({
    required Future<bool> Function() onPromptReauth,
  }) async {
    _isLoading = true;
    _errorKey = null;
    _customErrorMessage = null;
    notifyListeners();

    try {
      await _authService.deleteUserAccount();
      return true;
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'requires-recent-login') {
        _logger.w('Requires recent login. Prompting for re-auth.');
        final reauthenticated = await onPromptReauth();
        if (reauthenticated) {
          try {
            await _authService.deleteUserAccount();
            return true;
          } catch (e2, s2) {
            _logger.e('Failed to delete account AFTER re-auth', error: e2, stackTrace: s2);
            _errorKey = 'genericError';
            return false;
          }
        } else {
          _logger.w('Re-authentication cancelled or failed.');
          if (_authService.errorMessage != null) {
            _customErrorMessage = _authService.errorMessage;
          } else {
            _errorKey = 'genericError';
          }
          return false;
        }
      } else {
        _logger.e('FirebaseAuthException while deleting', error: e, stackTrace: s);
        _errorKey = 'genericError';
        return false;
      }
    } catch (e, s) {
      _logger.e('Generic error deleting user account', error: e, stackTrace: s);
      _errorKey = 'genericError';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
