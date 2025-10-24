import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {}

class MockFirebaseAppPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAppPlatform {}

const FirebaseOptions mockFirebaseOptions = FirebaseOptions(
  apiKey: 'mock-api-key',
  appId: 'mock-app-id',
  messagingSenderId: 'mock-sender-id',
  projectId: 'mock-project-id',
);

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockFirebasePlatform mockFirebasePlatform = MockFirebasePlatform();
  final MockFirebaseAppPlatform mockFirebaseAppPlatform =
      MockFirebaseAppPlatform();

  Firebase.delegatePackingProperty = mockFirebasePlatform;

  when(
    () => mockFirebasePlatform.initializeApp(
      name: any(named: 'name'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) async => mockFirebaseAppPlatform);

  when(
    () => mockFirebasePlatform.app(any()),
  ).thenReturn(mockFirebaseAppPlatform);
  when(() => mockFirebasePlatform.apps).thenReturn([mockFirebaseAppPlatform]);

  when(() => mockFirebaseAppPlatform.name).thenReturn('[DEFAULT]');
  when(() => mockFirebaseAppPlatform.options).thenReturn(mockFirebaseOptions);
}
