import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tax_code_flutter/screens/home_page.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/info_modal.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

class FakeLocale extends Fake implements Locale {}

void main() {
  setUpAll(() {
    setupTests();
  });

  late MockAuthService mockAuthService;
  late MockThemeService mockThemeService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockThemeService = MockThemeService();
    mockUser = MockUser();
  });

  group('HomePage Widget Tests', () {
    testWidgets('renders correctly with default state', (tester) async {
      // Arrange & Act
      await pumpApp(tester, const HomePage(), isSignedIn: true);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ContactsList), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('My Contacts'), findsOneWidget);
    });

    testWidgets('displays user avatar when photoURL is available', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        // Arrange
        when(
          () => mockUser.photoURL,
        ).thenReturn('https://example.com/avatar.png');
        when(() => mockAuthService.currentUser).thenReturn(mockUser);

        // Act
        await pumpApp(
          tester,
          const HomePage(),
          isSignedIn: true,
          mockAuthService: mockAuthService,
        );

        // Assert
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(find.byIcon(Symbols.account_circle_filled), findsNothing);
      });
    });

    testWidgets('displays placeholder icon when photoURL is null', (
      tester,
    ) async {
      when(() => mockUser.photoURL).thenReturn(null);
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      // Act
      await pumpApp(
        tester,
        const HomePage(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      // Assert
      expect(find.byIcon(Symbols.account_circle_filled), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('tapping theme button calls toggleTheme on ThemeService', (
      tester,
    ) async {
      // Arrange
      when(() => mockThemeService.theme).thenReturn('light');
      when(() => mockThemeService.toggleTheme()).thenAnswer((_) async {});

      // Act
      await pumpApp(
        tester,
        const HomePage(),
        isSignedIn: true,
        mockThemeService: mockThemeService,
      );

      await tester.tap(find.byIcon(Icons.mode_night_sharp));
      await tester.pump();

      // Assert
      verify(() => mockThemeService.toggleTheme()).called(1);
    });

    testWidgets('tapping info menu item shows InfoModal dialog', (
      tester,
    ) async {
      // Act
      await pumpApp(tester, const HomePage(), isSignedIn: true);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(InfoModal), findsOneWidget);
    });
  });
}
