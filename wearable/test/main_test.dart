import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/main.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';

import 'main_test.mocks.dart';

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  final _mockApp = MockFirebaseAppPlatform();

  @override
  Future<FirebaseAppPlatform> initializeApp(
      {String? name, FirebaseOptions? options}) async {
    return _mockApp;
  }

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return _mockApp;
  }

  @override
  List<FirebaseAppPlatform> get apps => [_mockApp];
}

class MockFirebaseAppPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAppPlatform {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: 'fake-app-id',
        messagingSenderId: 'fake-sender-id',
        projectId: 'fake-project-id',
      );
}

@GenerateMocks([AppState])
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    FirebasePlatform.instance = MockFirebasePlatform();

    await Firebase.initializeApp();
  });

  group('TaxCodeApp Routing', () {
    late MockAppState mockAppState;

    setUp(() {
      mockAppState = MockAppState();
      when(mockAppState.theme).thenReturn('light');
      when(mockAppState.contacts).thenReturn([]);

      const channel = MethodChannel('screen_brightness');
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return null;
      });
    });

    testWidgets('should navigate to BarcodePage with a valid tax code',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: const TaxCodeApp(),
        ),
      );

      final context = tester.element(find.byType(AuthGate));
      Navigator.of(context).pushNamed('/barcode?taxCode=RSSMRA80A01H501A');
      await tester.pumpAndSettle();

      expect(find.byType(BarcodePage), findsOneWidget);

      final barcodeWidget =
          tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodeWidget.data, 'RSSMRA80A01H501A'.codeUnits);
    });
  });
}
