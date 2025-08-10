import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';

import 'auth_gate_test.mocks.dart';

@GenerateMocks([
  AppState,
  auth.UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication
])
void main() {
  group('AuthGate UI States', () {
    testWidgets('shows Login UI when user is logged out', (tester) async {
      final mockAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthGate(
            firebaseAuth: mockAuth,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows HomePage when user is logged in', (tester) async {
      final mockAppState = MockAppState();
      final mockAuth = MockFirebaseAuth(signedIn: true);

      when(mockAppState.isLoading).thenReturn(false);
      when(mockAppState.contacts).thenReturn([]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(
              firebaseAuth: mockAuth,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('AuthGate Interaction', () {
    late MockAppState mockAppState;
    late MockFirebaseAuth mockAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

    setUp(() {
      mockAppState = MockAppState();
      mockAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    });

    testWidgets('tapping login button successfully signs in the user',
        (tester) async {
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.accessToken).thenReturn('fake_token');
      when(mockGoogleSignInAuthentication.idToken).thenReturn('fake_token');

      when(mockAppState.isLoading).thenReturn(false);
      when(mockAppState.contacts).thenReturn([]);
      when(mockAppState.saveUserData(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(
              firebaseAuth: mockAuth,
              googleSignIn: mockGoogleSignIn,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAppState.saveUserData(any)).called(1);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('does nothing when user cancels Google Sign-In',
        (tester) async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(
              firebaseAuth: mockAuth,
              googleSignIn: mockGoogleSignIn,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAppState.saveUserData(any));
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('shows SnackBar when Google Sign-In fails', (tester) async {
      when(mockGoogleSignIn.signIn())
          .thenThrow(Exception('Simulated network error'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(
              firebaseAuth: mockAuth,
              googleSignIn: mockGoogleSignIn,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAppState.saveUserData(any));
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
