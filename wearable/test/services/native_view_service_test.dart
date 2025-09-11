// test/services/native_view_service_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

//--- Mocks ---//
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
        // Arrange
        when(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).thenAnswer((_) async => true);

        // Act
        await nativeViewService.launchPhoneApp();

        // Assert
        verify(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).called(1);
        verifyNever(() => mockLogger.e(any()));
      });

      test('should log error and throw message on PlatformException', () async {
        // Arrange
        final exception = PlatformException(
          code: 'ERROR',
          message: 'Device not found',
        );
        when(
          () => mockMethodChannel.invokeMethod<bool>('launchPhoneApp'),
        ).thenThrow(exception);

        // Act
        final call = nativeViewService.launchPhoneApp;

        // Assert
        expect(call, throwsA(equals(exception.message)));
        verify(
          () => mockLogger.e(
            any(that: contains('Failed to invoke native launchPhoneApp')),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    group('showContactList', () {
      final contact = Contact(
        id: '12345',
        firstName: 'Mario',
        lastName: 'Rossi',
        gender: 'M',
        taxCode: 'RSSMRA80A01H501U',
        birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
        birthDate: DateTime(1980, 1, 1),
        listIndex: 0,
      );
      final contacts = [contact];
      final expectedArgs = {
        'contacts': contacts.map((c) => c.toNativeMap()).toList(),
      };

      test('should invoke method with correct arguments', () async {
        // Arrange
        when(
          () => mockMethodChannel.invokeMethod('openNativeContactList', any()),
        ).thenAnswer((_) async {});

        // Act
        await nativeViewService.showContactList(contacts);

        // Assert
        verify(
          () => mockMethodChannel.invokeMethod(
            'openNativeContactList',
            expectedArgs,
          ),
        ).called(1);
      });

      test('should log error and rethrow on PlatformException', () async {
        // Arrange
        final exception = PlatformException(code: 'ERROR');
        when(
          () => mockMethodChannel.invokeMethod('openNativeContactList', any()),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => nativeViewService.showContactList(contacts),
          throwsA(isA<PlatformException>()),
        );
        verify(
          () => mockLogger.e(
            any(that: contains('Failed to invoke native method')),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });
    });

    // Gli altri test rimangono invariati
    group('closeContactList', () {
      test('should invoke method on channel successfully', () async {
        when(
          () => mockMethodChannel.invokeMethod<void>('closeNativeContactList'),
        ).thenAnswer((_) async {});
        await nativeViewService.closeContactList();
        verify(
          () => mockMethodChannel.invokeMethod<void>('closeNativeContactList'),
        ).called(1);
      });
    });

    group('enableHighBrightnessMode', () {
      test('should invoke method on channel successfully', () async {
        when(
          () =>
              mockMethodChannel.invokeMethod<void>('enableHighBrightnessMode'),
        ).thenAnswer((_) async {});
        await nativeViewService.enableHighBrightnessMode();
        verify(
          () =>
              mockMethodChannel.invokeMethod<void>('enableHighBrightnessMode'),
        ).called(1);
      });
    });
  });
}
