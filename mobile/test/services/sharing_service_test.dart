import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

// --- Mocks per le nostre astrazioni ---
class MockShareAdapter extends Mock implements ShareAdapter {}

class MockLogger extends Mock implements Logger {}

void main() {
  late SharingService sharingService;
  late MockShareAdapter mockShareAdapter;
  late MockLogger mockLogger;

  setUp(() {
    mockShareAdapter = MockShareAdapter();
    mockLogger = MockLogger();
    registerFallbackValue(StackTrace.current);
    registerFallbackValue(Object());

    sharingService = SharingService(
      logger: mockLogger,
      shareAdapter: mockShareAdapter,
    );
  });

  const tText = 'test content';

  group('SharingService', () {
    test(
      'should return ShareResult with success status when sharing is successful',
      () async {
        // Arrange
        final successResult = const ShareResult(
          'com.example.app',
          ShareResultStatus.success,
        );
        when(
          () => mockShareAdapter.share(text: any(named: 'text')),
        ).thenAnswer((_) async => successResult);

        // Act
        final result = await sharingService.share(text: tText);

        // Assert
        expect(result.status, ShareResultStatus.success);
        verify(() => mockShareAdapter.share(text: tText)).called(1);
      },
    );

    test(
      'should return ShareResult with dismissed status when sharing is dismissed',
      () async {
        // Arrange
        final dismissedResult = const ShareResult(
          'com.example.app',
          ShareResultStatus.dismissed,
        );
        when(
          () => mockShareAdapter.share(text: any(named: 'text')),
        ).thenAnswer((_) async => dismissedResult);

        // Act
        final result = await sharingService.share(text: tText);

        // Assert
        expect(result.status, ShareResultStatus.dismissed);
      },
    );

    test(
      'should return ShareResult.unavailable and log error when sharing throws an exception',
      () async {
        // Arrange
        when(
          () => mockShareAdapter.share(text: any(named: 'text')),
        ).thenThrow(Exception('Platform error'));

        // Act
        final result = await sharingService.share(text: tText);

        // Assert
        expect(result, ShareResult.unavailable);
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
}
