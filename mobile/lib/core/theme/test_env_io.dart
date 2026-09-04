import 'dart:io' show Platform;

/// Returns true if currently executing in a Flutter unit/widget test runner.
bool get isFlutterTestEnvironment =>
    Platform.environment.containsKey('FLUTTER_TEST');
