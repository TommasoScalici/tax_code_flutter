import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/screens/auth_gate.dart';
import 'package:tax_code_flutter/screens/home_page.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

class FakeLocale extends Fake implements Locale {}

void main() {
  setUpAll(() {
    setupTests();
  });

  group('AuthGate Widget Tests', () {
    testWidgets('displays HomePage when user is signed in', (tester) async {
      // Arrange & Act
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.authenticated,
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SignInScreen), findsNothing);
    });

    testWidgets('displays SignInScreen when user is signed out', (
      tester,
    ) async {
      // Arrange & Act
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.unauthenticated,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('hides footer button on small screens when signed out', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(280 * 3.0, 800 * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.reset());

      // Act
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.unauthenticated,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.widgetWithText(TextButton, 'View Terms & Conditions'),
        findsNothing,
      );
    });

    testWidgets('shows footer button on large screens when signed out', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(400 * 3.0, 800 * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.reset());

      // Act
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.unauthenticated,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.widgetWithText(TextButton, 'View Terms & Conditions'),
        findsOneWidget,
      );
    });
  });
}
