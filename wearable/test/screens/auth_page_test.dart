import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';

//--- Mocks & Fakes ---//

class MockAuthService extends Mock implements AuthService {}

class FakeHomePage extends StatelessWidget {
  const FakeHomePage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late MockAuthService mockAuthService;

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: Settings.getWearTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: const AuthGate(homePage: FakeHomePage()),
        ),
      ),
    );
  }

  setUp(() {
    mockAuthService = MockAuthService();

    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
    when(
      () => mockAuthService.signInWithGoogleForWearable(),
    ).thenAnswer((_) async {});

    when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);
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

    testWidgets('displays LoginView when user is signed out (idle state)', (
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
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Login failed. Please try again.'), findsNothing);
    });

    testWidgets('displays loading indicator when authService is loading', (
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

      verifyNever(() => mockAuthService.signInWithGoogleForWearable());
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
  });
}
