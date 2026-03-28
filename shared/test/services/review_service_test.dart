import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  group('ReviewService', () {
    late ReviewService reviewService;
    late MockSharedPreferencesAsync mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      reviewService = ReviewService(prefs: mockPrefs);
    });

    group('recordFirstLaunchIfNeeded', () {
      test('should set timestamp when not already set', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer((_) async => null);
        when(
          () => mockPrefs.setInt('review_first_launch', any()),
        ).thenAnswer((_) async {});

        // Act
        await reviewService.recordFirstLaunchIfNeeded();

        // Assert
        verify(
          () => mockPrefs.setInt('review_first_launch', any()),
        ).called(1);
      });

      test('should not overwrite timestamp when already set', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer((_) async => 1000000);

        // Act
        await reviewService.recordFirstLaunchIfNeeded();

        // Assert
        verifyNever(
          () => mockPrefs.setInt('review_first_launch', any()),
        );
      });
    });

    group('incrementAppOpenCount', () {
      test('should start from 0 when no previous value', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => null);
        when(
          () => mockPrefs.setInt('review_app_open_count', 1),
        ).thenAnswer((_) async {});

        // Act
        await reviewService.incrementAppOpenCount();

        // Assert
        verify(
          () => mockPrefs.setInt('review_app_open_count', 1),
        ).called(1);
      });

      test('should increment from existing value', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 5);
        when(
          () => mockPrefs.setInt('review_app_open_count', 6),
        ).thenAnswer((_) async {});

        // Act
        await reviewService.incrementAppOpenCount();

        // Assert
        verify(
          () => mockPrefs.setInt('review_app_open_count', 6),
        ).called(1);
      });
    });

    group('shouldRequestReview', () {
      test('should return false when calculations < 2', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, false);
      });

      test('should return false when app opens < 3', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 3);
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 2);

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, false);
      });

      test('should return false when install age < 3 days', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 3);
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 5);
        // Installed just now
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer(
          (_) async => DateTime.now().millisecondsSinceEpoch,
        );

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, false);
      });

      test('should return false when prompted less than 90 days ago',
          () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 5);
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 10);
        // Installed 30 days ago
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch,
        );
        // Last prompted 10 days ago
        when(
          () => mockPrefs.getInt('review_last_prompt'),
        ).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(days: 10))
              .millisecondsSinceEpoch,
        );

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, false);
      });

      test('should return true when all conditions are met (never prompted)',
          () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 2);
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 3);
        // Installed 5 days ago
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(days: 5))
              .millisecondsSinceEpoch,
        );
        // Never prompted
        when(
          () => mockPrefs.getInt('review_last_prompt'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, true);
      });

      test(
          'should return true when all conditions met and '
          'last prompt > 90 days ago', () async {
        // Arrange
        when(
          () => mockPrefs.getInt('review_successful_calculations'),
        ).thenAnswer((_) async => 10);
        when(
          () => mockPrefs.getInt('review_app_open_count'),
        ).thenAnswer((_) async => 50);
        // Installed 120 days ago
        when(
          () => mockPrefs.getInt('review_first_launch'),
        ).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(days: 120))
              .millisecondsSinceEpoch,
        );
        // Last prompted 100 days ago
        when(
          () => mockPrefs.getInt('review_last_prompt'),
        ).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(days: 100))
              .millisecondsSinceEpoch,
        );

        // Act
        final result = await reviewService.shouldRequestReview();

        // Assert
        expect(result, true);
      });
    });
  });
}
