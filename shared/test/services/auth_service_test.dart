// auth_service_test.dart

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

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

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

    when(
      () => mockAuth.authStateChanges(),
    ).thenAnswer((_) => authStreamController.stream);
    when(() => mockDbService.saveUserData(any())).thenAnswer((_) async {});
    when(
      () => mockLogger.e(
        any(),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenAnswer((_) {});
    when(() => mockLogger.w(any())).thenAnswer((_) {});
    when(() => mockLogger.i(any())).thenAnswer((_) {});

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

    test(
      'should update user and state when auth state changes to a new user',
      () async {
        // Arrange
        final mockUser = MockUser();

        // Act
        authStreamController.add(mockUser);
        await pumpEventQueue();

        // Assert
        expect(authService.isSignedIn, isTrue);
        expect(authService.currentUser, mockUser);
        verify(() => mockDbService.saveUserData(mockUser)).called(1);
      },
    );

    test('should clear user when auth state changes to null', () async {
      authStreamController.add(null);
      await pumpEventQueue();
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('should log an error if saving user data fails after login', () async {
      // Arrange
      final mockUser = MockUser();
      final exception = Exception('Firestore connection failed');
      when(() => mockDbService.saveUserData(mockUser)).thenThrow(exception);

      // Act
      authStreamController.add(mockUser);
      await pumpEventQueue();

      // Assert
      expect(authService.isSignedIn, isTrue);
      expect(authService.currentUser, mockUser);

      verify(
        () => mockLogger.e(
          'Error while storing user data',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });

  group('signInWithGoogleForWearable', () {
    final mockGoogleAccount = MockGoogleSignInAccount();
    final mockGoogleAuth = MockGoogleSignInAuthentication();
    final mockCredential = MockUserCredential();

    setUp(() {
      when(
        () => mockGoogleAccount.authentication,
      ).thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(() => mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(
        () => mockAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => mockCredential);
    });

    test(
      'should complete sign-in flow and update loading state on success',
      () async {
        // Arrange
        when(
          () => mockGoogleSignIn.signIn(),
        ).thenAnswer((_) async => mockGoogleAccount);
        final loadingStates = <bool>[];
        authService.addListener(() {
          loadingStates.add(authService.isLoading);
        });

        // Act
        await authService.signInWithGoogleForWearable();

        // Assert
        verify(() => mockAuth.signInWithCredential(any())).called(1);
        expect(loadingStates, [true, false]);
      },
    );

    test('should handle user cancelling the sign-in flow', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      final loadingStates = <bool>[];
      authService.addListener(() {
        loadingStates.add(authService.isLoading);
      });

      // Act
      await authService.signInWithGoogleForWearable();

      // Assert
      verifyNever(() => mockAuth.signInWithCredential(any()));
      verify(
        () => mockLogger.w('Google Sign-In was cancelled by the user.'),
      ).called(1);
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
      verify(
        () => mockLogger.e(
          'Error during Google Sign-In',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      expect(loadingStates, [true, false]);
      expect(authService.errorMessage, isNotNull);
    });
  });

  group('deleteUserAccount', () {
    final userToDelete = MockUser();

    setUp(() {
      when(() => userToDelete.uid).thenReturn('test_uid');
      when(
        () => mockDbService.deleteAllUserData(any()),
      ).thenAnswer((_) async {});
      when(() => userToDelete.delete()).thenAnswer((_) async {});
    });

    test('should do nothing if user is not signed in', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      await authService.deleteUserAccount();

      // Assert
      verifyNever(() => mockDbService.deleteAllUserData(any()));
      verifyNever(() => userToDelete.delete());
    });

    test(
      'should call deleteAllUserData and user.delete, then log success',
      () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(userToDelete);

        // Act
        await authService.deleteUserAccount();

        // Assert
        verifyInOrder([
          () => mockDbService.deleteAllUserData('test_uid'),
          () => userToDelete.delete(),
        ]);
        verify(
          () => mockLogger.i(
            'User account and all associated data deleted successfully.',
          ),
        ).called(1);
      },
    );

    test('should rethrow and log error if dbService fails', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(userToDelete);
      final exception = Exception('Firestore failed');
      when(() => mockDbService.deleteAllUserData(any())).thenThrow(exception);

      // Act
      final future = authService.deleteUserAccount();

      // Assert
      await expectLater(future, throwsA(isA<Exception>()));
      verify(
        () => mockLogger.e(
          'Error deleting user account',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verifyNever(() => userToDelete.delete());
    });

    test('should rethrow and log error if user.delete() fails', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(userToDelete);
      final exception = FirebaseAuthException(code: 'requires-recent-login');
      when(() => userToDelete.delete()).thenThrow(exception);

      // Act
      final future = authService.deleteUserAccount();

      // Assert
      await expectLater(future, throwsA(isA<FirebaseAuthException>()));
      verify(
        () => mockLogger.e(
          'Error deleting user account',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });

  group('signOut', () {
    test(
      'should call sign out on both FirebaseAuth and GoogleSignIn',
      () async {
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
      },
    );

    test(
      'should attempt Firebase sign-out even if Google sign-out fails',
      () async {
        // Arrange
        final exception = Exception('Google Sign-Out failed');
        when(() => mockGoogleSignIn.signOut()).thenThrow(exception);
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(
          () => mockLogger.e(
            'Error during Google sign out',
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);

        verify(() => mockAuth.signOut()).called(1);
      },
    );

    test(
      'should attempt Google sign-out even if Firebase sign-out fails',
      () async {
        // Arrange
        final exception = Exception('Firebase Sign-Out failed');
        when(() => mockAuth.signOut()).thenThrow(exception);
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
          return null;
        });

        // Act
        await authService.signOut();

        // Assert
        verify(
          () => mockLogger.e(
            'Error during Firebase sign out',
            error: exception,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      },
    );
  });
}
