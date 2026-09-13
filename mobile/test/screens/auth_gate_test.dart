import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/screens/auth_gate.dart';
import 'package:tax_code_flutter/screens/home_page.dart';
import 'package:tax_code_flutter/screens/welcome_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(setupTests);

  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.isGuest).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);
    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});
  });

  group('AuthGate Widget Tests', () {
    testWidgets('renders HomePage when status is authenticated', (tester) async {
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.authenticated,
        mockAuthService: mockAuthService,
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('renders WelcomeScreen when status is unauthenticated', (tester) async {
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.unauthenticated,
        mockAuthService: mockAuthService,
      );

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('renders CircularProgressIndicator when status is initializing', (tester) async {
      await pumpApp(
        tester,
        const AuthGate(),
        authStatus: AuthStatus.initializing,
        mockAuthService: mockAuthService,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(WelcomeScreen), findsNothing);
    });
  });
}
