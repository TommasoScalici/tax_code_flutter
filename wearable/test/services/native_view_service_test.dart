import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class MockLogger extends Mock implements Logger {}

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  late NativeViewService nativeViewService;
  late MockLogger mockLogger;
  late MockMethodChannel mockMethodChannel;

  setUp(() {
    mockLogger = MockLogger();
    mockMethodChannel = MockMethodChannel();
    nativeViewService = NativeViewService(
      logger: mockLogger,
      platform: mockMethodChannel,
    );
  });

  group('NativeViewService', () {
    group('launchPhoneApp', () {
      test('should invoke method on channel successfully', () async {
        when(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).thenAnswer((_) async => true);

        await nativeViewService.launchPhoneApp();

        verify(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).called(1);
        verifyNever(() => mockLogger.e(any<Object?>()));
      });

      test('should log error and throw message on PlatformException', () async {
        final exception = PlatformException(
          code: 'ERROR',
          message: 'Device not found',
        );
        when(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).thenThrow(exception);

        expect(
          () => nativeViewService.launchPhoneApp(),
          throwsA(isA<PlatformException>()),
        );
        verify(
          () => mockLogger.e(
            any<Object?>(
              that: contains('Failed to invoke native launchPhoneApp'),
            ),
            error: exception,
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    group('enableHighBrightnessMode', () {
      test('should invoke method on channel successfully', () async {
        when(
          () => mockMethodChannel.invokeMethod<void>('enableHighBrightnessMode'),
        ).thenAnswer((_) async {});

        await nativeViewService.enableHighBrightnessMode();

        verify(
          () => mockMethodChannel.invokeMethod<void>('enableHighBrightnessMode'),
        ).called(1);
      });

      test('should log error and throw on PlatformException', () async {
        final exception = PlatformException(code: 'ERROR', message: 'Failed');
        when(
          () => mockMethodChannel.invokeMethod<void>('enableHighBrightnessMode'),
        ).thenThrow(exception);

        expect(
          () => nativeViewService.enableHighBrightnessMode(),
          throwsA(isA<PlatformException>()),
        );
        verify(
          () => mockLogger.e(
            any<Object?>(
              that: contains('Failed to invoke enableHighBrightnessMode'),
            ),
            error: exception,
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    group('disableHighBrightnessMode', () {
      test('should invoke method on channel successfully', () async {
        when(
          () =>
              mockMethodChannel.invokeMethod<void>('disableHighBrightnessMode'),
        ).thenAnswer((_) async {});

        await nativeViewService.disableHighBrightnessMode();

        verify(
          () =>
              mockMethodChannel.invokeMethod<void>('disableHighBrightnessMode'),
        ).called(1);
      });

      test('should log error and throw on PlatformException', () async {
        final exception = PlatformException(code: 'ERROR', message: 'Failed');
        when(
          () =>
              mockMethodChannel.invokeMethod<void>('disableHighBrightnessMode'),
        ).thenThrow(exception);

        expect(
          () => nativeViewService.disableHighBrightnessMode(),
          throwsA(isA<PlatformException>()),
        );
        verify(
          () => mockLogger.e(
            any<Object?>(
              that: contains('Failed to invoke disableHighBrightnessMode'),
            ),
            error: exception,
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });
  });
}
