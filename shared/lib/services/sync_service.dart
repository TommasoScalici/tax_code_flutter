import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the state and persistence of cloud synchronization for contacts.
///
/// Features:
/// - Persists user sync preference across sessions using [SharedPreferencesAsync].
/// - Evaluates whether sync is possible ([canSync]) based on [AuthService] state:
///   only authenticated Google users (non-guest) can perform cloud sync.
/// - Automatically notifies listeners when auth state changes or sync is toggled.
class SyncService with ChangeNotifier {
  /// The key used to store the cloud sync setting in persistent storage.
  static const String prefKey = 'cloud_sync_enabled';

  final SharedPreferencesAsync _prefs;
  final AuthService _authService;

  bool _isUserSyncEnabled = true;
  bool _isDisposed = false;

  /// Creates a new [SyncService] instance.
  SyncService({
    required SharedPreferencesAsync prefs,
    required AuthService authService,
  })  : _prefs = prefs,
        _authService = authService {
    _authService.addListener(_onAuthChanged);
  }

  /// Whether the current authenticated user has access to cloud synchronization.
  /// Always false for guests or unauthenticated users.
  bool get canSync => _authService.isSignedIn && !_authService.isGuest;

  /// Whether cloud sync is actively enabled and running for the current session.
  bool get isSyncEnabled => canSync && _isUserSyncEnabled;

  /// The user's explicit preference regarding sync (independent of whether guest/logged out).
  bool get isUserSyncEnabled => _isUserSyncEnabled;

  /// Loads the persisted sync preference from storage.
  Future<void> init() async {
    _isUserSyncEnabled = await _prefs.getBool(prefKey) ?? true;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Explicitly sets and persists whether cloud sync is enabled.
  Future<void> setSyncEnabled(bool enabled) async {
    if (_isUserSyncEnabled == enabled) return;
    _isUserSyncEnabled = enabled;
    await _prefs.setBool(prefKey, enabled);
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Toggles the user's sync preference and persists the new state.
  Future<void> toggleSync() async {
    await setSyncEnabled(!_isUserSyncEnabled);
  }

  void _onAuthChanged() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
