import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/screens/welcome_screen.dart';
import 'package:tax_code_flutter/widgets/profile/profile_app_info_view.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';

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
    when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.isGuest).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);
    when(() => mockAuthService.errorKey).thenReturn(null);
    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
  });

  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders app icon, headline, subtitle, buttons, and terms', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      // Verify headline & subtitle
      expect(find.text('Your Tax Codes, always with you'), findsOneWidget);
      expect(
        find.text('Save, access, and show your codes at pharmacies or offices in an instant.'),
        findsOneWidget,
      );

      // Verify buttons
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);

      // Verify terms link
      expect(find.text('View Terms & Conditions'), findsOneWidget);
    });

    testWidgets('tapping Google button calls authService.signInWithGoogle', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.signInWithGoogle()).thenAnswer((_) async => true);

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      verify(() => mockAuthService.signInWithGoogle()).called(1);
    });

    testWidgets('tapping Guest button calls authService.signInAnonymously', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.signInAnonymously()).thenAnswer((_) async => true);

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Continue as guest'));
      await tester.pump();

      verify(() => mockAuthService.signInAnonymously()).called(1);
    });

    testWidgets('displays loading indicator when authService.isLoading is true', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.isLoading).thenReturn(true);

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows snackbar when signInWithGoogle fails with error message', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.signInWithGoogle()).thenAnswer((_) async => false);
      when(() => mockAuthService.errorKey).thenReturn('networkError');
      when(() => mockAuthService.errorMessage).thenReturn('networkError');

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          'No internet connection. Please check your network and try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when signInAnonymously fails with error message', (tester) async {
      setMobileSize(tester);
      when(() => mockAuthService.signInAnonymously()).thenAnswer((_) async => false);
      when(() => mockAuthService.errorKey).thenReturn('signInFailed');
      when(() => mockAuthService.errorMessage).thenReturn('signInFailed');

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sign-in failed. Please try again.'), findsOneWidget);
    });

    testWidgets('tapping terms link opens ProfileBottomSheet with legal info', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const WelcomeScreen(),
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('View Terms & Conditions'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomSheet), findsOneWidget);
      expect(find.byType(ProfileAppInfoView), findsOneWidget);
    });
  });
}
