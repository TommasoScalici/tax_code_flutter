import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/screens/profile_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

class MockFirebaseAuthException extends Fake implements FirebaseAuthException {
  @override
  final String code;

  MockFirebaseAuthException({required this.code});
}

void main() {
  setUpAll(() {
    setupTests();
  });

  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockUser.photoURL).thenReturn(null);
  });

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders basic UI elements', (tester) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('Test User');

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('displays correct user displayName', (tester) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('Tommaso Scalici');

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      // Assert
      expect(find.text('Tommaso Scalici'), findsOneWidget);
      expect(find.text('Test User'), findsNothing);
    });

    testWidgets('tapping Sign Out button calls authService.signOut', (
      tester,
    ) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      // Assert
      verify(() => mockAuthService.signOut()).called(1);
    });

    testWidgets('tapping Delete Account button shows confirmation dialog', (
      tester,
    ) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tapping Cancel on delete dialog dismisses dialog', (
      tester,
    ) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping Delete on dialog calls deleteUserAccount', (
      tester,
    ) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');
      when(() => mockAuthService.deleteUserAccount()).thenAnswer((_) async {});

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthService.deleteUserAccount()).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows SnackBar if signOut fails', (tester) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');
      when(
        () => mockAuthService.signOut(),
      ).thenThrow(Exception('Network error'));

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows recent login dialog if delete fails', (tester) async {
      // Arrange
      when(() => mockUser.displayName).thenReturn('');
      when(
        () => mockAuthService.deleteUserAccount(),
      ).thenThrow(MockFirebaseAuthException(code: 'requires-recent-login'));
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      // Act
      await pumpApp(
        tester,
        const ProfileScreen(),
        isSignedIn: true,
        mockAuthService: mockAuthService,
      );

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Confirmation'), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Action Required'), findsOneWidget);
    });
  });
}
