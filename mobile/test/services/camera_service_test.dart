import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tax_code_flutter/services/camera_service.dart';

//--- Mocks ---//
class MockLogger extends Mock implements Logger {}

// CORREZIONE: Aggiunto "with MockPlatformInterfaceMixin"
class MockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {}

void main() {
  late CameraService cameraService;
  late MockLogger mockLogger;
  late MockCameraPlatform mockCameraPlatform;

  setUp(() {
    mockLogger = MockLogger();
    cameraService = CameraService(logger: mockLogger);

    mockCameraPlatform = MockCameraPlatform();
    CameraPlatform.instance = mockCameraPlatform;
  });

  group('CameraService', () {
    group('getAvailableCameras', () {
      test('should return a list of CameraDescription on success', () async {
        // Arrange
        final fakeCameras = [
          const CameraDescription(
            name: '0',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ];
        when(
          () => mockCameraPlatform.availableCameras(),
        ).thenAnswer((_) async => fakeCameras);

        // Act
        final result = await cameraService.getAvailableCameras();

        // Assert
        expect(result, equals(fakeCameras));
        verifyNever(() => mockLogger.e(any()));
      });

      test(
        'should return an empty list and log a CameraException on failure',
        () async {
          // Arrange
          final exception = CameraException('ERROR', 'Camera not available');
          when(
            () => mockCameraPlatform.availableCameras(),
          ).thenThrow(exception);

          // Act
          final result = await cameraService.getAvailableCameras();

          // Assert
          expect(result, isEmpty);
          verify(
            () => mockLogger.e(
              'Failed to get available cameras',
              error: any(named: 'error', that: isA<CameraException>()),
              stackTrace: any(named: 'stackTrace'),
              time: any(named: 'time'),
            ),
          ).called(1);
        },
      );
    });
  });
}
