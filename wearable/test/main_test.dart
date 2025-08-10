import 'dart:async';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/main.dart';
import 'package:tax_code_flutter_wear_os/main.dart' as app;
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';

import 'helpers/firebase_test_setup.dart';
import 'main_test.mocks.dart';

@GenerateMocks([
  AppState,
  Logger,
  FirebaseRemoteConfig,
  FirebaseAppCheck,
  FirebaseCrashlytics,
])
void main() {
  setUpAll(() async {
    await setupMockFirebase();
  });

  // --- Main Function ---

  group('Main Function Execution', () {
    testWidgets('main() should build the app and display AuthGate',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await app.main();
      await tester.pumpAndSettle();

      expect(find.byType(TaxCodeApp), findsOneWidget);
      expect(find.byType(AuthGate), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  // --- Config Tests ---
  group('App Configuration', () {
    late MockLogger mockLogger;
    late MockFirebaseAppCheck mockAppCheck;
    late MockFirebaseCrashlytics mockCrashlytics;
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() {
      mockLogger = MockLogger();
      mockAppCheck = MockFirebaseAppCheck();
      mockCrashlytics = MockFirebaseCrashlytics();
      mockRemoteConfig = MockFirebaseRemoteConfig();
    });

    test('should not initialize Firebase if not on Android', () async {
      await configureApp(logger: mockLogger, isAndroid: false, isDebug: true);
      verifyZeroInteractions(mockLogger);
    });

    test(
        'should initialize Firebase and activate AppCheck in debug mode on Android',
        () async {
      when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
      when(mockAppCheck.activate(androidProvider: AndroidProvider.debug))
          .thenAnswer((_) async {});

      await configureApp(
        logger: mockLogger,
        isAndroid: true,
        isDebug: true,
        remoteConfig: mockRemoteConfig,
        appCheck: mockAppCheck,
        crashlytics: mockCrashlytics,
      );

      verify(mockRemoteConfig.fetchAndActivate()).called(1);
      verify(mockAppCheck.activate(androidProvider: AndroidProvider.debug))
          .called(1);
      verifyNever(mockAppCheck.activate(
          androidProvider: AndroidProvider.playIntegrity));
      verifyZeroInteractions(mockLogger);
    });

    test(
        'should activate AppCheck with Play Integrity in release mode on Android',
        () async {
      /// Arrange: Setup mock behaviors for release mode
      when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
      when(mockAppCheck.activate(
              androidProvider: AndroidProvider.playIntegrity))
          .thenAnswer((_) async {});

      /// Act: Call the function with isDebug: false
      await configureApp(
        logger: mockLogger,
        isAndroid: true,
        isDebug: false,
        remoteConfig: mockRemoteConfig,
        appCheck: mockAppCheck,
        crashlytics: mockCrashlytics,
      );

      /// Assert: Verify the correct provider is used
      verify(mockAppCheck.activate(
              androidProvider: AndroidProvider.playIntegrity))
          .called(1);
      verifyNever(
          mockAppCheck.activate(androidProvider: AndroidProvider.debug));
    });

    test('should log an error if Firebase configuration fails', () async {
      /// Arrange: Make one of the Firebase calls throw an exception
      final exception = Exception('Failed to connect to Firebase');
      when(mockRemoteConfig.fetchAndActivate()).thenThrow(exception);

      /// Act: Call the function
      await configureApp(
        logger: mockLogger,
        isAndroid: true,
        isDebug: true,
        remoteConfig: mockRemoteConfig,
        appCheck: mockAppCheck,
        crashlytics: mockCrashlytics,
      );

      /// Assert: Verify that the logger's error method was called
      verify(mockLogger.e(any)).called(1);
    });

    testWidgets('should record a Flutter error via Crashlytics',
        (tester) async {
      final originalOnError = FlutterError.onError;

      try {
        /// Arrange
        when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
        await configureApp(
          logger: mockLogger,
          isAndroid: true,
          isDebug: true,
          crashlytics: mockCrashlytics,
          remoteConfig: mockRemoteConfig,
          appCheck: mockAppCheck,
        );

        /// Act: Pump a "broken" widget that will throw a layout error.
        await tester.pumpWidget(const Directionality(
          textDirection: TextDirection.ltr,
          child: Row(children: [SizedBox(width: double.infinity)]),
        ));

        /// Assert: Check that Crashlytics was called.
        verify(mockCrashlytics.recordFlutterFatalError(any)).called(2);
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    test('should assign a handler to PlatformDispatcher that records errors',
        () async {
      /// Arrange
      when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
      await configureApp(
        logger: mockLogger,
        isAndroid: true,
        isDebug: true,
        appCheck: mockAppCheck,
        crashlytics: mockCrashlytics,
        remoteConfig: mockRemoteConfig,
      );

      final platformErrorHandler = PlatformDispatcher.instance.onError;

      expect(platformErrorHandler, isNotNull);

      /// Act
      final exception = Exception('Fake async platform error');
      final stack = StackTrace.current;

      platformErrorHandler!(exception, stack);

      /// Assert
      verify(mockCrashlytics.recordError(exception, stack, fatal: true))
          .called(1);
    });
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
      unawaited(
          Navigator.of(context).pushNamed('/barcode?taxCode=RSSMRA80A01H501A'));
      await tester.pumpAndSettle();

      expect(find.byType(BarcodePage), findsOneWidget);
      final barcodeWidget =
          tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
      expect(barcodeWidget.data, 'RSSMRA80A01H501A'.codeUnits);
    });

    // --- Routing Tests ---

    testWidgets('should show fallback UI for route without taxCode parameter',
        (WidgetTester tester) async {
      /// Pump the main app widget.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: const TaxCodeApp(),
        ),
      );

      /// Navigate to the barcode route but without the required parameter.
      final context = tester.element(find.byType(AuthGate));
      unawaited(Navigator.of(context).pushNamed('/barcode'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      /// Verify that the BarcodePage is not shown and the fallback UI is.
      expect(find.byType(BarcodePage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show fallback UI for an unknown route',
        (WidgetTester tester) async {
      /// Pump the main app widget.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: const TaxCodeApp(),
        ),
      );

      /// Navigate to a completely unknown route.
      final context = tester.element(find.byType(AuthGate));
      unawaited(Navigator.of(context).pushNamed('/some/unknown/route'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      /// Verify that the BarcodePage is not shown and the fallback UI is.
      expect(find.byType(BarcodePage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display the correct app title based on localization',
        (WidgetTester tester) async {
      /// Pump the app. This will build the MaterialApp.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: const TaxCodeApp(),
        ),
      );

      final titleFinder = find.byType(Title);
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Title>(titleFinder);
      expect(titleWidget.title, 'Tax Code');
    });
  });
}
