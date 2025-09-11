import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tax_code_flutter/services/permission_service.dart';

// --- Mocks ---
class MockPermissionHandlerAdapter extends Mock
    implements PermissionHandlerAdapter {}

class MockLogger extends Mock implements Logger {}

void main() {
  late PermissionService permissionService;
  late MockPermissionHandlerAdapter mockPermissionHandler;
  late MockLogger mockLogger;

  setUp(() {
    mockPermissionHandler = MockPermissionHandlerAdapter();
    mockLogger = MockLogger();
    registerFallbackValue(StackTrace.current);
    registerFallbackValue(Object());

    permissionService = PermissionService(
      logger: mockLogger,
      permissionHandler: mockPermissionHandler,
    );
  });

  group('PermissionService', () {
    group('requestCameraPermission', () {
      test('should return true when camera permission is granted', () async {
        // Arrange
        when(
          () => mockPermissionHandler.requestCamera(),
        ).thenAnswer((_) async => PermissionStatus.granted);

        // Act
        final result = await permissionService.requestCameraPermission();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when camera permission is denied', () async {
        // Arrange
        when(
          () => mockPermissionHandler.requestCamera(),
        ).thenAnswer((_) async => PermissionStatus.denied);

        // Act
        final result = await permissionService.requestCameraPermission();

        // Assert
        expect(result, isFalse);
      });

      test(
        'should return false and log error when request throws an exception',
        () async {
          // Arrange
          when(
            () => mockPermissionHandler.requestCamera(),
          ).thenThrow(Exception('Platform error'));

          // Act
          final result = await permissionService.requestCameraPermission();

          // Assert
          expect(result, isFalse);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        },
      );
    });

    group('openAppSettingsHandler', () {
      test(
        'should return true when app settings are opened successfully',
        () async {
          // Arrange
          when(
            () => mockPermissionHandler.openSettings(),
          ).thenAnswer((_) async => true);

          // Act
          final result = await permissionService.openAppSettingsHandler();

          // Assert
          expect(result, isTrue);
        },
      );

      test('should return false when opening app settings fails', () async {
        // Arrange
        when(
          () => mockPermissionHandler.openSettings(),
        ).thenAnswer((_) async => false);

        // Act
        final result = await permissionService.openAppSettingsHandler();

        // Assert
        expect(result, isFalse);
      });

      test(
        'should return false and log error when opening settings throws an exception',
        () async {
          // Arrange
          when(
            () => mockPermissionHandler.openSettings(),
          ).thenThrow(Exception('Platform error'));

          // Act
          final result = await permissionService.openAppSettingsHandler();

          // Assert
          expect(result, isFalse);
          verify(
            () => mockLogger.e(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        },
      );
    });
  });
}
