import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/user_avatar.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(setupTests);

  late MockAuthService mockAuthService;

  void setMobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.status).thenReturn(AuthStatus.authenticated);
    when(() => mockAuthService.isSignedIn).thenReturn(true);
    when(() => mockAuthService.isGuest).thenReturn(false);
    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
  });

  group('DashboardHeader Widget Tests', () {
    testWidgets('renders brand subtitle and dashboard title by default', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          appBar: DashboardHeader(
            title: 'I Miei Codici',
            subtitle: 'Codice Fiscale',
          ),
        ),
        mockAuthService: mockAuthService,
      );

      expect(find.text('CODICE FISCALE'), findsOneWidget);
      expect(find.text('I Miei Codici'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('renders custom title and subtitle when provided', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          appBar: DashboardHeader(
            title: 'I Miei Documenti',
            subtitle: 'Archivio',
          ),
        ),
        mockAuthService: mockAuthService,
      );

      expect(find.text('ARCHIVIO'), findsOneWidget);
      expect(find.text('I Miei Documenti'), findsOneWidget);
    });

    testWidgets('tapping theme button triggers onThemeToggle callback', (tester) async {
      setMobileSize(tester);
      var themeToggled = false;

      await pumpApp(
        tester,
        Scaffold(
          appBar: DashboardHeader(
            onThemeToggle: () {
              themeToggled = true;
            },
          ),
        ),
        mockAuthService: mockAuthService,
      );

      final themeButton = find.byKey(const Key('dashboard_header_theme_button'));
      expect(themeButton, findsOneWidget);

      await tester.tap(themeButton);
      await tester.pump();

      expect(themeToggled, isTrue);
    });

    testWidgets('tapping cloud sync button triggers onSyncToggle callback when authenticated', (tester) async {
      setMobileSize(tester);
      var syncToggled = false;

      await pumpApp(
        tester,
        Scaffold(
          appBar: DashboardHeader(
            onSyncToggle: () {
              syncToggled = true;
            },
          ),
        ),
        mockAuthService: mockAuthService,
      );

      final syncButton = find.byKey(const Key('dashboard_header_sync_button'));
      expect(syncButton, findsOneWidget);

      await tester.tap(syncButton);
      await tester.pump();

      expect(syncToggled, isTrue);
    });

    testWidgets('tapping cloud sync button as guest displays informative snackbar', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.isGuest).thenReturn(true);

      await pumpApp(
        tester,
        const Scaffold(
          appBar: DashboardHeader(),
        ),
        mockAuthService: mockAuthService,
        locale: const Locale('it'),
      );

      final syncButton = find.byKey(const Key('dashboard_header_sync_button'));
      expect(syncButton, findsOneWidget);

      await tester.tap(syncButton);
      await tester.pump();

      expect(
        find.text('Accedi con Google per sincronizzare i tuoi codici tra dispositivi'),
        findsOneWidget,
      );
    });

    testWidgets('tapping profile avatar triggers onProfileTap callback', (tester) async {
      setMobileSize(tester);
      var profileTapped = false;

      await pumpApp(
        tester,
        Scaffold(
          appBar: DashboardHeader(
            onProfileTap: () {
              profileTapped = true;
            },
          ),
        ),
        mockAuthService: mockAuthService,
      );

      final avatarFinder = find.byType(UserAvatar);
      expect(avatarFinder, findsOneWidget);

      await tester.tap(avatarFinder);
      await tester.pump();

      expect(profileTapped, isTrue);
    });

    testWidgets('shows cloud sync badge when user is authenticated with Google', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.isGuest).thenReturn(false);

      await pumpApp(
        tester,
        const Scaffold(
          appBar: DashboardHeader(),
        ),
        mockAuthService: mockAuthService,
        authStatus: AuthStatus.authenticated,
      );

      expect(find.byKey(const Key('dashboard_header_sync_badge')), findsOneWidget);
    });

    testWidgets('hides cloud sync badge when user is a guest', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(() => mockAuthService.isGuest).thenReturn(true);

      await pumpApp(
        tester,
        const Scaffold(
          appBar: DashboardHeader(),
        ),
        mockAuthService: mockAuthService,
      );

      expect(find.byKey(const Key('dashboard_header_sync_badge')), findsNothing);
      expect(find.byType(UserAvatar), findsOneWidget);
    });
  });
}
