import 'dart:io';

void main() {
  _ensureStub('mobile/lib/firebase_options.dart');
  _ensureStub('wearable/lib/firebase_options.dart');
}

void _ensureStub(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('''
// Generated stub for CI and static analysis when firebase_options.dart is git-ignored.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: '1:000000000000:android:000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tax-code-flutter',
    storageBucket: 'tax-code-flutter.firebasestorage.app',
  );
}
''');
    stdout.writeln('Generated stub for $filePath');
  } else {
    stdout.writeln('Using existing $filePath');
  }
}
