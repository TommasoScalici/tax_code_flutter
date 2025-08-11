import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  group('ThemeService', () {
    late ThemeService themeService;
    late MockSharedPreferencesAsync mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      themeService = ThemeService(prefs: mockPrefs);
    });

    test('should have light theme as default', () {
      // Assert
      expect(themeService.theme, 'light');
    });

    test('should initialize with theme from preferences', () async {
      // Arrange
      when(() => mockPrefs.getString('theme')).thenAnswer((_) async => 'dark');

      // Act
      await themeService.init();

      // Assert
      expect(themeService.theme, 'dark');
      verify(() => mockPrefs.getString('theme')).called(1);
    });

    test('should toggle theme from light to dark and save it', () {
      // Arrange
      when(
        () => mockPrefs.setString('theme', 'dark'),
      ).thenAnswer((_) async => true);

      // Act
      themeService.toggleTheme();

      // Assert
      expect(themeService.theme, 'dark');
      verify(() => mockPrefs.setString('theme', 'dark')).called(1);
    });

    test('should toggle theme from dark to light and save it', () async {
      // Arrange
      when(() => mockPrefs.getString('theme')).thenAnswer((_) async => 'dark');
      await themeService.init();
      when(
        () => mockPrefs.setString('theme', 'light'),
      ).thenAnswer((_) async => true);

      // Act
      themeService.toggleTheme();

      // Assert
      expect(themeService.theme, 'light');
      verify(() => mockPrefs.setString('theme', 'light')).called(1);
    });
  });
}
