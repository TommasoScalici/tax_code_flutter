import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';

//--- Mocks & Fakes ---//

class MockAuthService extends Mock implements AuthService {}

class MockDemoModeService extends Mock implements DemoModeServiceAbstract {}

class FakeHomePage extends StatelessWidget {
  const FakeHomePage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late MockAuthService mockAuthService;
  late MockDemoModeService mockDemoModeService;

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: Settings.getWearTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
            ChangeNotifierProvider<DemoModeServiceAbstract>.value(
              value: mockDemoModeService,
            ),
          ],
          child: const AuthGate(homePage: FakeHomePage()),
        ),
      ),
    );
  }

  setUp(() {
    mockAuthService = MockAuthService();
    mockDemoModeService = MockDemoModeService();

    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
    when(
      () => mockAuthService.signInWithGoogleForWearable(),
    ).thenAnswer((_) async {});

    when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);

    when(() => mockDemoModeService.addListener(any())).thenAnswer((_) {});
    when(() => mockDemoModeService.removeListener(any())).thenAnswer((_) {});
    when(() => mockDemoModeService.isDemoMode).thenReturn(false);
    when(() => mockDemoModeService.enableDemoMode()).thenReturn(null);
  });

  group('AuthGate Widget', () {
    testWidgets('displays loading indicator when status is initializing', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.initializing);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FakeHomePage), findsNothing);
      expect(find.text('Welcome to Tax Code'), findsNothing);
    });

    testWidgets('displays HomePage when user is signed in', (tester) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.authenticated);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(FakeHomePage), findsOneWidget);
    });

    testWidgets('displays HomePage when isDemoMode is true', (tester) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockDemoModeService.isDemoMode).thenReturn(true);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(FakeHomePage), findsOneWidget);
    });

    testWidgets('displays LoginView with demo button when user is signed out', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockAuthService.isLoading).thenReturn(false);
      when(() => mockAuthService.errorMessage).thenReturn(null);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(FakeHomePage), findsNothing);
      expect(find.text('Welcome to Tax Code'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Demo Mode'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Login failed. Please try again.'), findsNothing);
    });

    testWidgets('displays loading indicator and disables demo button when loading', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockAuthService.isLoading).thenReturn(true);
      when(() => mockAuthService.errorMessage).thenReturn(null);

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Sign In with Google'));
      await tester.tap(find.text('Demo Mode'));

      verifyNever(() => mockAuthService.signInWithGoogleForWearable());
      verifyNever(() => mockDemoModeService.enableDemoMode());
    });

    testWidgets('displays error message when authService has an error', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockAuthService.isLoading).thenReturn(false);
      when(() => mockAuthService.errorMessage).thenReturn('An error occurred');

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.text('Login failed. Please try again.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Sign In with Google'));
      verify(() => mockAuthService.signInWithGoogleForWearable()).called(1);
    });

    testWidgets('calls signInWithGoogleForWearable when button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockAuthService.isLoading).thenReturn(false);
      when(() => mockAuthService.errorMessage).thenReturn(null);
      when(
        () => mockAuthService.signInWithGoogleForWearable(),
      ).thenAnswer((_) async {});

      await pumpWidget(tester);

      // Act
      await tester.tap(find.text('Sign In with Google'));

      // Assert
      verify(() => mockAuthService.signInWithGoogleForWearable()).called(1);
    });

    testWidgets('calls enableDemoMode when Demo Mode button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
      when(() => mockAuthService.isLoading).thenReturn(false);
      when(() => mockAuthService.errorMessage).thenReturn(null);

      await pumpWidget(tester);

      // Act
      await tester.tap(find.text('Demo Mode'));

      // Assert
      verify(() => mockDemoModeService.enableDemoMode()).called(1);
    });
  });
}
