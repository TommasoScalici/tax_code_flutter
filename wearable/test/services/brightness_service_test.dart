import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:tax_code_flutter_wear_os/services/brightness_service.dart';

class MockLogger extends Mock implements Logger {}
class MockScreenBrightness extends Mock implements ScreenBrightness {}
class MockScreenBrightnessPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ScreenBrightnessPlatform {}

void main() {
  late BrightnessService brightnessService;
  late MockLogger mockLogger;
  late MockScreenBrightness mockScreenBrightness;

  setUp(() {
    mockLogger = MockLogger();
    mockScreenBrightness = MockScreenBrightness();

    brightnessService = BrightnessService(
      logger: mockLogger,
      brightness: mockScreenBrightness,
    );
    
    when(() => mockLogger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
        .thenAnswer((_) {});
  });

  group('setMaxBrightness', () {
    test('should call setApplicationScreenBrightness with 1.0 on success', () async {
      // Arrange
      when(() => mockScreenBrightness.setApplicationScreenBrightness(1.0))
          .thenAnswer((_) async {});

      // Act
      await brightnessService.setMaxBrightness();

      // Assert
      verify(() => mockScreenBrightness.setApplicationScreenBrightness(1.0)).called(1);
    });

    test('should log an error when setApplicationScreenBrightness fails', () async {
      // Arrange
      final exception = Exception('Platform error');
      when(() => mockScreenBrightness.setApplicationScreenBrightness(1.0))
          .thenThrow(exception);

      // Act
      await brightnessService.setMaxBrightness();

      // Assert
      verify(() => mockLogger.e(
        'Failed to set max brightness',
        error: exception,
        stackTrace: any(named: 'stackTrace'),
      )).called(1);
    });
  });

  group('resetBrightness', () {
    test('should call resetApplicationScreenBrightness on success', () async {
      // Arrange
      when(() => mockScreenBrightness.resetApplicationScreenBrightness())
          .thenAnswer((_) async {});

      // Act
      await brightnessService.resetBrightness();

      // Assert
      verify(() => mockScreenBrightness.resetApplicationScreenBrightness()).called(1);
    });

    test('should log an error when resetApplicationScreenBrightness fails', () async {
      // Arrange
      final exception = Exception('Platform error');
      when(() => mockScreenBrightness.resetApplicationScreenBrightness())
          .thenThrow(exception);
      
      // Act
      await brightnessService.resetBrightness();

      // Assert
      verify(() => mockLogger.e(
        'Failed to reset brightness',
        error: exception,
        stackTrace: any(named: 'stackTrace'),
      )).called(1);
    });

    test('should use default ScreenBrightness instance when none is provided', () async {
      // Arrange
      final mockPlatform = MockScreenBrightnessPlatform();
      ScreenBrightnessPlatform.instance = mockPlatform;

      when(() => mockPlatform.setApplicationScreenBrightness(1.0)).thenAnswer((_) async {});
      
      final serviceWithDefault = BrightnessService(logger: MockLogger());

      // Act
      await serviceWithDefault.setMaxBrightness();

      // Assert
      verify(() => mockPlatform.setApplicationScreenBrightness(1.0)).called(1);
    });
  });
}