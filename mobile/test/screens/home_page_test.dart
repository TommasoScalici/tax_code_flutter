import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:tax_code_flutter/screens/home_page.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/user_avatar.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

class FakeLocale extends Fake implements Locale {}

void main() {
  setUpAll(setupTests);

  late MockAuthService mockAuthService;
  late MockThemeService mockThemeService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockThemeService = MockThemeService();
    mockUser = MockUser();
  });

  group('HomePage Widget Tests', () {
    testWidgets('renders correctly with default state without contacts (hides FAB)', (
      tester,
    ) async {
      // Arrange & Act
      await pumpApp(
        tester,
        const HomePage(),
        authStatus: AuthStatus.authenticated,
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ContactsList), findsOneWidget);
      // FloatingActionButton must be hidden when there are no contacts to avoid clutter
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('My Codes'), findsOneWidget);
    });

    testWidgets('displays FloatingActionButton when at least one contact exists', (
      tester,
    ) async {
      final mockContactRepository = MockContactRepository();
      when(() => mockContactRepository.isLoading).thenReturn(false);
      when(() => mockContactRepository.contacts).thenReturn([
        Contact(
          id: '1',
          firstName: 'Mario',
          lastName: 'Rossi',
          gender: 'M',
          birthDate: DateTime(1985, 4, 15),
          birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
          taxCode: 'RSSMRA85D15H501Z',
          listIndex: 0,
        ),
      ]);

      await pumpApp(
        tester,
        const HomePage(),
        authStatus: AuthStatus.authenticated,
        mockContactRepository: mockContactRepository,
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FloatingActionButton), findsOneWidget);
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
          authStatus: AuthStatus.authenticated,
          mockAuthService: mockAuthService,
        );

        // Assert
        expect(
          find.descendant(
            of: find.byType(UserAvatar),
            matching: find.byType(ClipRRect),
          ),
          findsOneWidget,
        );
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
        authStatus: AuthStatus.authenticated,
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
      when(() => mockThemeService.theme).thenReturn(AppThemeMode.light);
      when(() => mockThemeService.toggleTheme()).thenAnswer((_) async {});

      // Act
      await pumpApp(
        tester,
        const HomePage(),
        authStatus: AuthStatus.authenticated,
        mockThemeService: mockThemeService,
      );

      await tester.tap(
        find.byKey(const Key('dashboard_header_theme_button')),
      );
      await tester.pump();

      // Assert
      verify(() => mockThemeService.toggleTheme()).called(1);
    });

    testWidgets('tapping profile avatar navigates to profile', (
      tester,
    ) async {
      // Act
      await pumpApp(
        tester,
        const HomePage(),
        authStatus: AuthStatus.authenticated,
      );

      expect(find.byType(UserAvatar), findsOneWidget);
      await tester.tap(find.byType(UserAvatar));
      await tester.pumpAndSettle();
    });
  });
}
