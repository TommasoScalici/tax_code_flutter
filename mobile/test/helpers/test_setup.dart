import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import 'firebase_test_setup.dart';

class FakeLocale extends Fake implements Locale {}

void setupTests() {
  setupFirebaseMocks();
  registerFallbackValue(FakeLocale());
}
