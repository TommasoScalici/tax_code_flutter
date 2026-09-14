import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/services/gemini_service.dart';

import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';

import '../helpers/mocks.dart';

// region Mocks and Fake Classes
class MockCameraService extends Mock implements CameraServiceAbstract {}

class MockGeminiService extends Mock implements GeminiServiceAbstract {}

class MockPermissionService extends Mock implements PermissionServiceAbstract {}

class MockLogger extends Mock implements Logger {}

class FakeXFile extends XFile {
  FakeXFile(super.path);
}

class FakeScannedData extends Fake implements ScannedData {}

class FakeCameraValue extends Fake implements CameraValue {
  @override
  DeviceOrientation get deviceOrientation => DeviceOrientation.portraitUp;

  @override
  bool get isInitialized => true;
}
// endregion

void main() {
  late CameraPageController cameraPageController;
  late MockCameraService mockCameraService;
  late MockGeminiService mockGeminiService;
  late MockPermissionService mockPermissionService;
  late MockLogger mockLogger;
  late MockCameraController mockCameraController;
  late CameraControllerFactory mockFactory;

  setUpAll(() {
    registerFallbackValue(FlashMode.off);
    registerFallbackValue(FakeCameraDescription());
  });

  setUp(() {
    mockCameraService = MockCameraService();
    mockGeminiService = MockGeminiService();
    mockPermissionService = MockPermissionService();
    mockLogger = MockLogger();
    mockCameraController = MockCameraController();

    when(
      () => mockLogger.e(
        any<Object?>(),
        error: any<Object?>(named: 'error'),
        stackTrace: any<StackTrace?>(named: 'stackTrace'),
      ),
    ).thenAnswer((_) {});
    when(() => mockLogger.i(any<Object?>())).thenAnswer((_) {});

    when(() => mockCameraController.dispose()).thenAnswer((_) async {});
    when(
      () => mockCameraController.setFlashMode(any()),
    ).thenAnswer((_) async {});

    mockFactory = (
      desc,
      preset, {
      enableAudio = false,
    }) => mockCameraController;

    cameraPageController = CameraPageController(
      cameraService: mockCameraService,
      geminiService: mockGeminiService,
      permissionService: mockPermissionService,
      logger: mockLogger,
      cameraControllerFactory: mockFactory,
    );
  });

  tearDown(() {
    cameraPageController.dispose();
  });

  group('CameraPageController', () {
    test('initial status is "initializing"', () {
      expect(cameraPageController.status, CameraStatus.initializing);
    });

    group('initialize', () {
      test(
        'sets status to permissionDenied when permission is not granted',
        () async {
          when(
            () => mockPermissionService.requestCameraPermission(),
          ).thenAnswer((_) async => false);
          await cameraPageController.initialize();
          expect(cameraPageController.status, CameraStatus.permissionDenied);
          verifyNever(() => mockCameraService.getAvailableCameras());
        },
      );

      test('sets status to error when no cameras are found', () async {
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCameraService.getAvailableCameras(),
        ).thenAnswer((_) async => []);
        await cameraPageController.initialize();
        expect(cameraPageController.status, CameraStatus.error);
        verify(
          () => mockLogger.e(
            any<Object?>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).called(1);
      });

      test('sets status to readyToScan on successful initialization', () async {
        // Arrange
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCameraService.getAvailableCameras(),
        ).thenAnswer((_) async => [FakeCameraDescription()]);
        when(() => mockCameraController.initialize()).thenAnswer((_) async {});

        // Act
        await cameraPageController.initialize();

        // Assert
        expect(cameraPageController.status, CameraStatus.readyToScan);
        verify(() => mockCameraController.initialize()).called(1);
      });
    });

    Future<void> initializeControllerSuccessfully() async {
      when(
        () => mockPermissionService.requestCameraPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => mockCameraService.getAvailableCameras(),
      ).thenAnswer((_) async => [FakeCameraDescription()]);
      when(() => mockCameraController.initialize()).thenAnswer((_) async {});
      await cameraPageController.initialize();
    }

    group('with initialized camera', () {
      setUp(() {
        when(() => mockCameraController.dispose()).thenAnswer((_) async {});
        when(
          () => mockCameraController.setFlashMode(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockCameraController.pausePreview(),
        ).thenAnswer((_) async {});
        when(
          () => mockCameraController.resumePreview(),
        ).thenAnswer((_) async {});
        when(() => mockCameraController.value).thenReturn(FakeCameraValue());
      });

      test('takePicture updates status and imagePath on success', () async {
        // Arrange
        await initializeControllerSuccessfully();
        final fakeImage = FakeXFile('path/to/fake_image.jpg');
        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => fakeImage);

        // Act
        await cameraPageController.takePicture();

        // Assert
        expect(cameraPageController.status, CameraStatus.pictureTaken);
        expect(cameraPageController.imagePath, 'path/to/fake_image.jpg');
        verify(() => mockCameraController.takePicture()).called(1);
        verify(() => mockCameraController.pausePreview()).called(1);
      });

      test('resetPicture resumes preview, clears imagePath and deletes temp file', () async {
        // Arrange
        await initializeControllerSuccessfully();
        final tempDir = await Directory.systemTemp.createTemp();
        final fakeImageFile = File('${tempDir.path}/fake_image.jpg');
        await fakeImageFile.writeAsBytes([1, 2, 3]);
        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(fakeImageFile.path));
        await cameraPageController.takePicture();
        expect(await fakeImageFile.exists(), isTrue);

        // Act
        await cameraPageController.resetPicture();

        // Assert
        expect(cameraPageController.status, CameraStatus.readyToScan);
        expect(cameraPageController.imagePath, isNull);
        expect(await fakeImageFile.exists(), isFalse);
        verify(() => mockCameraController.resumePreview()).called(1);

        await tempDir.delete(recursive: true);
      });

      test('takePicture and resetPicture lifecycle cleans temp files', () async {
        // Arrange
        await initializeControllerSuccessfully();
        final tempDir = await Directory.systemTemp.createTemp();
        final firstImageFile = File('${tempDir.path}/first_image.jpg');
        await firstImageFile.writeAsBytes([1, 2, 3]);
        final secondImageFile = File('${tempDir.path}/second_image.jpg');
        await secondImageFile.writeAsBytes([4, 5, 6]);

        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(firstImageFile.path));
        await cameraPageController.takePicture();
        expect(await firstImageFile.exists(), isTrue);

        // Act & Assert: reset cleans up first file
        await cameraPageController.resetPicture();
        expect(await firstImageFile.exists(), isFalse);

        // Second picture
        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(secondImageFile.path));
        await cameraPageController.takePicture();
        expect(await secondImageFile.exists(), isTrue);

        await cameraPageController.resetPicture();
        expect(await secondImageFile.exists(), isFalse);

        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('dispose deletes temp file if exists', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp();
        final fakeImageFile = File('${tempDir.path}/fake_image.jpg');
        await fakeImageFile.writeAsBytes([1, 2, 3]);

        final localController = CameraPageController(
          cameraService: mockCameraService,
          geminiService: mockGeminiService,
          permissionService: mockPermissionService,
          logger: mockLogger,
          cameraControllerFactory: mockFactory,
        );
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCameraService.getAvailableCameras(),
        ).thenAnswer((_) async => [FakeCameraDescription()]);
        when(() => mockCameraController.initialize()).thenAnswer((_) async {});
        await localController.initialize();

        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(fakeImageFile.path));
        await localController.takePicture();
        expect(await fakeImageFile.exists(), isTrue);

        // Act
        localController.dispose();
        await pumpEventQueue();

        // Assert
        expect(await fakeImageFile.exists(), isFalse);

        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('confirmAndProcessPicture uses custom imageProcessor', () async {
        // Arrange
        var customProcessorCalled = false;
        final customController = CameraPageController(
          cameraService: mockCameraService,
          geminiService: mockGeminiService,
          permissionService: mockPermissionService,
          logger: mockLogger,
          cameraControllerFactory: mockFactory,
          imageProcessor: (filePath) async {
            customProcessorCalled = true;
            return 'custom_base64_data';
          },
        );

        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCameraService.getAvailableCameras(),
        ).thenAnswer((_) async => [FakeCameraDescription()]);
        when(() => mockCameraController.initialize()).thenAnswer((_) async {});
        await customController.initialize();

        final tempDir = await Directory.systemTemp.createTemp();
        final fakeImageFile = File('${tempDir.path}/fake_image.jpg');
        await fakeImageFile.writeAsBytes([1, 2, 3]);
        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(fakeImageFile.path));
        await customController.takePicture();

        when(
          () => mockGeminiService.extractDataFromDocument('custom_base64_data'),
        ).thenAnswer((_) async => FakeScannedData());

        // Act
        final result = await customController.confirmAndProcessPicture();

        // Assert
        expect(result, isA<ScannedData>());
        expect(customProcessorCalled, isTrue);
        verify(
          () => mockGeminiService.extractDataFromDocument('custom_base64_data'),
        ).called(1);

        customController.dispose();
        await pumpEventQueue();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('lifecycle paused disposes camera controller and resumed reinitializes', () async {
        // Arrange
        await initializeControllerSuccessfully();
        expect(cameraPageController.cameraController, isNotNull);

        // Act 1: Pause app
        cameraPageController.didChangeAppLifecycleState(AppLifecycleState.paused);
        // Let async unawaited complete
        await pumpEventQueue();

        // Assert 1: Controller disposed and nulled
        expect(cameraPageController.cameraController, isNull);
        verify(() => mockCameraController.dispose()).called(1);

        // Act 2: Resume app
        cameraPageController.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await pumpEventQueue();

        // Assert 2: Controller reinitialized
        expect(cameraPageController.cameraController, isNotNull);
      });

      test('confirmAndProcessPicture returns ScannedData on success', () async {
        // Arrange 1
        await initializeControllerSuccessfully();
        final tempDir = await Directory.systemTemp.createTemp();
        final fakeImageFile = File('${tempDir.path}/fake_image.jpg');
        await fakeImageFile.writeAsBytes([1, 2, 3]);
        when(
          () => mockCameraController.takePicture(),
        ).thenAnswer((_) async => FakeXFile(fakeImageFile.path));
        await cameraPageController.takePicture();

        // Arrange 2
        final fakeScannedData = FakeScannedData();
        when(
          () => mockGeminiService.extractDataFromDocument(any()),
        ).thenAnswer((_) async => fakeScannedData);

        // Act
        final result = await cameraPageController.confirmAndProcessPicture();

        // Assert
        expect(result, isA<ScannedData>());
        expect(cameraPageController.status, CameraStatus.pictureTaken);
        verify(
          () => mockGeminiService.extractDataFromDocument(any()),
        ).called(1);

        await tempDir.delete(recursive: true);
      });
    });

    test('openAppSettingsHandler calls permission service', () async {
      when(
        () => mockPermissionService.openAppSettingsHandler(),
      ).thenAnswer((_) async => true);
      await cameraPageController.openAppSettingsHandler();
      verify(() => mockPermissionService.openAppSettingsHandler()).called(1);
    });
  });
}
