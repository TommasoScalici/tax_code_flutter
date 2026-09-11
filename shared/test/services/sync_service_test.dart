import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('SyncService', () {
    late SyncService syncService;
    late MockSharedPreferencesAsync mockPrefs;
    late MockAuthService mockAuthService;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      mockAuthService = MockAuthService();
      when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
      when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(() => mockAuthService.isGuest).thenReturn(false);

      syncService = SyncService(
        prefs: mockPrefs,
        authService: mockAuthService,
      );
    });

    test('should have isUserSyncEnabled as true by default', () {
      expect(syncService.isUserSyncEnabled, isTrue);
      expect(syncService.canSync, isTrue);
      expect(syncService.isSyncEnabled, isTrue);
    });

    test('should have canSync as false if user is guest', () {
      when(() => mockAuthService.isGuest).thenReturn(true);
      expect(syncService.canSync, isFalse);
      expect(syncService.isSyncEnabled, isFalse);
    });

    test('should have canSync as false if user is not signed in', () {
      when(() => mockAuthService.isSignedIn).thenReturn(false);
      expect(syncService.canSync, isFalse);
      expect(syncService.isSyncEnabled, isFalse);
    });

    test('should load persisted preference on init', () async {
      when(() => mockPrefs.getBool(SyncService.prefKey))
          .thenAnswer((_) async => false);

      await syncService.init();

      expect(syncService.isUserSyncEnabled, isFalse);
      expect(syncService.isSyncEnabled, isFalse);
      verify(() => mockPrefs.getBool(SyncService.prefKey)).called(1);
    });

    test('setSyncEnabled should persist value and notify listeners', () async {
      when(() => mockPrefs.setBool(SyncService.prefKey, false))
          .thenAnswer((_) async => true);

      var notified = false;
      syncService.addListener(() => notified = true);

      await syncService.setSyncEnabled(false);

      expect(syncService.isUserSyncEnabled, isFalse);
      expect(notified, isTrue);
      verify(() => mockPrefs.setBool(SyncService.prefKey, false)).called(1);
    });

    test('toggleSync should invert state and persist', () async {
      when(() => mockPrefs.setBool(SyncService.prefKey, false))
          .thenAnswer((_) async => true);

      await syncService.toggleSync();

      expect(syncService.isUserSyncEnabled, isFalse);
      verify(() => mockPrefs.setBool(SyncService.prefKey, false)).called(1);
    });
  });
}
