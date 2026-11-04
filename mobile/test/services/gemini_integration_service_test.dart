import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/services/gemini_integration_service.dart';

import '../helpers/mocks.dart';

void main() {
  group('GeminiIntegrationService', () {
    late MockSharedPreferences mockPrefs;
    late MockLogger mockLogger;
    late GeminiIntegrationService service;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockLogger = MockLogger();
      service = GeminiIntegrationService(prefs: mockPrefs, logger: mockLogger);
    });

    test('defaults to enabled before init', () {
      expect(service.isGeminiEnabled, isTrue);
    });

    test('init loads stored value from SharedPreferences', () async {
      when(
        () => mockPrefs.getBool(GeminiIntegrationService.prefKey),
      ).thenAnswer((_) async => false);

      var notified = false;
      service.addListener(() => notified = true);

      await service.init();

      expect(service.isGeminiEnabled, isFalse);
      expect(notified, isTrue);
    });

    test('init defaults to true when storage returns null', () async {
      when(
        () => mockPrefs.getBool(GeminiIntegrationService.prefKey),
      ).thenAnswer((_) async => null);

      await service.init();

      expect(service.isGeminiEnabled, isTrue);
    });

    test('setGeminiEnabled persists value and notifies listeners', () async {
      when(
        () => mockPrefs.setBool(GeminiIntegrationService.prefKey, false),
      ).thenAnswer((_) async {});

      var notified = false;
      service.addListener(() => notified = true);

      await service.setGeminiEnabled(false);

      expect(service.isGeminiEnabled, isFalse);
      expect(notified, isTrue);
      verify(
        () => mockPrefs.setBool(GeminiIntegrationService.prefKey, false),
      ).called(1);
    });

    test('setGeminiEnabled does nothing when value has not changed', () async {
      var notified = false;
      service.addListener(() => notified = true);

      await service.setGeminiEnabled(true);

      expect(notified, isFalse);
      verifyNever(() => mockPrefs.setBool(any(), any()));
    });

    test('toggleGeminiEnabled flips current state', () async {
      when(
        () => mockPrefs.setBool(GeminiIntegrationService.prefKey, false),
      ).thenAnswer((_) async {});

      await service.toggleGeminiEnabled();

      expect(service.isGeminiEnabled, isFalse);
      verify(
        () => mockPrefs.setBool(GeminiIntegrationService.prefKey, false),
      ).called(1);
    });
  });
}
