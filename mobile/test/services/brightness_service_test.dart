import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';

//--- Mock ---//
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BrightnessService brightnessService;
  late MockLogger mockLogger;

  const MethodChannel channel = MethodChannel(
    'github.com/aaassseee/screen_brightness',
  );

  setUp(() {
    mockLogger = MockLogger();
    brightnessService = BrightnessService(logger: mockLogger);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('BrightnessService', () {
    group('setMaxBrightness', () {
      test(
        'should call platform channel to set brightness to 1.0 on success',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                expect(methodCall.method, 'setApplicationScreenBrightness');
                return null;
              });
          await brightnessService.setMaxBrightness();
          verifyNever(() => mockLogger.e(any()));
        },
      );

      test('should log an error when setting max brightness fails', () async {
        // Arrange
        final exception = PlatformException(code: 'ERROR');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) {
              return Future.error(exception);
            });

        // Act
        await brightnessService.setMaxBrightness();

        // Assert
        verify(
          () => mockLogger.e(
            'Failed to set max brightness',
            error: any(named: 'error', that: isA<PlatformException>()),
            stackTrace: any(named: 'stackTrace'),
            time: any(named: 'time'),
          ),
        ).called(1);
      });
    });

    group('resetBrightness', () {
      test(
        'should call platform channel to reset brightness on success',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                expect(methodCall.method, 'resetApplicationScreenBrightness');
                return null;
              });
          await brightnessService.resetBrightness();
          verifyNever(() => mockLogger.e(any()));
        },
      );

      test('should log an error when resetting brightness fails', () async {
        // Arrange
        final exception = PlatformException(code: 'ERROR');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) {
              return Future.error(exception);
            });

        // Act
        await brightnessService.resetBrightness();

        // Assert
        verify(
          () => mockLogger.e(
            'Failed to reset brightness',
            error: any(named: 'error', that: isA<PlatformException>()),
            stackTrace: any(named: 'stackTrace'),
            time: any(named: 'time'),
          ),
        ).called(1);
      });
    });
  });
}
