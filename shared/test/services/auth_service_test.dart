import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';

// --- Mocks ---
class FakeAuthCredential extends Fake implements AuthCredential {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDatabaseService extends Mock implements DatabaseService {}
class MockLogger extends Mock implements Logger {}
class MockUser extends Mock implements User {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockDatabaseService mockDbService;
  late MockLogger mockLogger;
  late StreamController<User?> authStreamController;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    authStreamController = StreamController<User?>.broadcast();
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockDbService = MockDatabaseService();
    mockLogger = MockLogger();

    when(() => mockAuth.authStateChanges()).thenAnswer((_) => authStreamController.stream);
    when(() => mockDbService.saveUserData(any())).thenAnswer((_) async {});
    when(() => mockLogger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.w(any())).thenAnswer((_) {});

    authService = AuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      dbService: mockDbService,
      logger: mockLogger,
    );
  });

  tearDown(() {
    authStreamController.close();
    authService.dispose();
  });

  group('Auth State Listening', () {
    test('should be signed out initially', () {
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.isLoading, isFalse);
    });

    test('should update user and state when auth state changes to a new user', () async {
      // Arrange
      final mockUser = MockUser();

      // Act
      authStreamController.add(mockUser);
      await pumpEventQueue();

      // Assert
      expect(authService.isSignedIn, isTrue);
      expect(authService.currentUser, mockUser);
      verify(() => mockDbService.saveUserData(mockUser)).called(1);
    });

     test('should clear user when auth state changes to null', () async {
      authStreamController.add(null);
      await pumpEventQueue();
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
    });
  });

  group('signInWithGoogleForWearable', () {
    final mockGoogleAccount = MockGoogleSignInAccount();
    final mockGoogleAuth = MockGoogleSignInAuthentication();
    final mockCredential = MockUserCredential();

    setUp(() {
      when(() => mockGoogleAccount.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(() => mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(() => mockAuth.signInWithCredential(any())).thenAnswer((_) async => mockCredential);
    });

    test('should complete sign-in flow and update loading state on success', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleAccount);
      final loadingStates = <bool>[];
      authService.addListener(() {
        loadingStates.add(authService.isLoading);
      });

      // Act
      await authService.signInWithGoogleForWearable();

      // Assert
      verify(() => mockAuth.signInWithCredential(any())).called(1);
      expect(loadingStates, [true, false]);
    });

    test('should handle user cancelling the sign-in flow', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null); // L'utente annulla
      final loadingStates = <bool>[];
      authService.addListener(() {
        loadingStates.add(authService.isLoading);
      });

      // Act
      await authService.signInWithGoogleForWearable();

      // Assert
      verifyNever(() => mockAuth.signInWithCredential(any()));
      verify(() => mockLogger.w('Google Sign-In was cancelled by the user.')).called(1);
      expect(loadingStates, [true, false]);
    });

     test('should handle and log exceptions during sign-in', () async {
      // Arrange
      final exception = Exception('Network Error');
      when(() => mockGoogleSignIn.signIn()).thenThrow(exception);
       final loadingStates = <bool>[];
      authService.addListener(() {
        loadingStates.add(authService.isLoading);
      });

      // Act
      await authService.signInWithGoogleForWearable();

      // Assert
      verify(() => mockLogger.e('Error during Google Sign-In', error: exception, stackTrace: any(named: 'stackTrace'))).called(1);
      expect(loadingStates, [true, false]);
    });
  });

  group('signOut', () {
    test('should call sign out on both FirebaseAuth and GoogleSignIn', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
        return null;
      });

      // Act
      await authService.signOut();

      // Assert
      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}