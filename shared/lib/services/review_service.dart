import 'package:shared_preferences/shared_preferences.dart';

/// A service that tracks user engagement milestones and determines
/// whether to show an in-app review prompt.
///
/// Uses [SharedPreferencesAsync] to persist counters and timestamps
/// across sessions. The logic intentionally avoids prompting too early
/// or too often, following Google's best practices.
class ReviewService {
  static const String _keySuccessfulCalculations =
      'review_successful_calculations';
  static const String _keyAppOpenCount = 'review_app_open_count';
  static const String _keyFirstLaunchTimestamp = 'review_first_launch';
  static const String _keyLastPromptTimestamp = 'review_last_prompt';

  static const int _minSuccessfulCalculations = 2;
  static const int _minAppOpens = 3;
  static const int _minDaysSinceInstall = 3;
  static const int _minDaysBetweenPrompts = 90;

  final SharedPreferencesAsync _prefs;

  ReviewService({required SharedPreferencesAsync prefs}) : _prefs = prefs;

  /// Records the first launch timestamp if it hasn't been set yet.
  /// Should be called once during app startup.
  Future<void> recordFirstLaunchIfNeeded() async {
    final existing = await _prefs.getInt(_keyFirstLaunchTimestamp);
    if (existing == null) {
      await _prefs.setInt(
        _keyFirstLaunchTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Increments the app open counter. Call on each app startup.
  Future<void> incrementAppOpenCount() async {
    final current = await _prefs.getInt(_keyAppOpenCount) ?? 0;
    await _prefs.setInt(_keyAppOpenCount, current + 1);
  }

  /// Increments the successful tax code calculation counter.
  /// Call after each successful calculation + save.
  Future<void> incrementSuccessfulCalculations() async {
    final current = await _prefs.getInt(_keySuccessfulCalculations) ?? 0;
    await _prefs.setInt(_keySuccessfulCalculations, current + 1);
  }

  /// Records that a review prompt was shown. Call immediately after
  /// triggering the native review dialog.
  Future<void> recordReviewPromptShown() async {
    await _prefs.setInt(
      _keyLastPromptTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Evaluates whether all conditions for showing a review prompt are met.
  ///
  /// Conditions (ALL must be true):
  /// - At least [_minSuccessfulCalculations] successful calculations
  /// - At least [_minAppOpens] app opens
  /// - At least [_minDaysSinceInstall] days since first launch
  /// - Never prompted before OR at least [_minDaysBetweenPrompts] days
  ///   since the last prompt
  Future<bool> shouldRequestReview() async {
    final calculations = await _prefs.getInt(_keySuccessfulCalculations) ?? 0;
    if (calculations < _minSuccessfulCalculations) return false;

    final appOpens = await _prefs.getInt(_keyAppOpenCount) ?? 0;
    if (appOpens < _minAppOpens) return false;

    final firstLaunchMs = await _prefs.getInt(_keyFirstLaunchTimestamp);
    if (firstLaunchMs == null) return false;

    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final daysSinceInstall = DateTime.now().difference(firstLaunch).inDays;
    if (daysSinceInstall < _minDaysSinceInstall) return false;

    final lastPromptMs = await _prefs.getInt(_keyLastPromptTimestamp);
    if (lastPromptMs != null) {
      final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;
      if (daysSinceLastPrompt < _minDaysBetweenPrompts) return false;
    }

    return true;
  }
}
