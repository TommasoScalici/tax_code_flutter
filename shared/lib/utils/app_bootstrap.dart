import 'package:logger/logger.dart';

/// Runs the given [configure] callback within a standard error-handling
/// wrapper. Both the mobile and wearable apps pass their Firebase setup
/// (Remote Config, App Check, Crashlytics) as the [configure] callback.
///
/// This keeps Firebase-specific dependencies out of the shared package
/// while centralizing the bootstrap error-handling pattern.
Future<void> configureApp({
  required Logger logger,
  required Future<void> Function() configure,
}) async {
  try {
    await configure();
  } on Exception catch (e, s) {
    logger.e(
      'Error while configuring the app with Firebase',
      error: e,
      stackTrace: s,
    );
  }
}
