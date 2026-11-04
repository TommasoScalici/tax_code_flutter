import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's opt-in/opt-out preference for Google Gemini and Android AppFunctions.
///
/// When disabled, all on-device Gemini AppFunctions reject execution with an
/// `AppFunctionDisabledException`, ensuring complete local privacy control.
class GeminiIntegrationService with ChangeNotifier {
  /// Storage key for persisting the Gemini integration preference.
  static const String prefKey = 'gemini_integration_enabled';

  final SharedPreferencesAsync _prefs;
  final Logger? _logger;

  bool _isGeminiEnabled = true;
  bool _isDisposed = false;

  GeminiIntegrationService({
    required SharedPreferencesAsync prefs,
    Logger? logger,
  }) : _prefs = prefs,
       _logger = logger;

  /// Whether Google Gemini and AppFunctions integration is currently enabled by the user.
  bool get isGeminiEnabled => _isGeminiEnabled;

  /// Loads the persisted integration preference from storage.
  Future<void> init() async {
    try {
      final stored = await _prefs.getBool(prefKey);
      _isGeminiEnabled = stored ?? true;
      if (!_isDisposed) {
        notifyListeners();
      }
    } on Exception catch (e, st) {
      _logger?.e(
        'Failed to read gemini_integration_enabled from storage',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Sets and persists whether Gemini integration is enabled.
  Future<void> setGeminiEnabled(bool enabled) async {
    if (_isGeminiEnabled == enabled) return;
    _isGeminiEnabled = enabled;
    try {
      await _prefs.setBool(prefKey, enabled);
      _logger?.d('Gemini integration preference updated: $enabled');
    } on Exception catch (e, st) {
      _logger?.e(
        'Failed to persist gemini_integration_enabled',
        error: e,
        stackTrace: st,
      );
    }
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Toggles the current integration preference.
  Future<void> toggleGeminiEnabled() async {
    await setGeminiEnabled(!_isGeminiEnabled);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
