import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';

// --- Mocks ---
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLogger extends Mock implements Logger {}

class MockUser extends Mock implements User {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockDatabaseService mockDbService;
    late MockLogger mockLogger;
    late MockUser mockUser;
    late StreamController<User?> authStreamController;

    setUpAll(() {
      registerFallbackValue(MockUser());
    });

    setUp(() {
      // --- Arrange for every test ---
      authStreamController = StreamController<User?>();
      mockUser = MockUser();
      mockAuth = MockFirebaseAuth();
      mockDbService = MockDatabaseService();
      mockLogger = MockLogger();

      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => authStreamController.stream);
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockDbService.saveUserData(any())).thenAnswer((_) async {});

      authService = AuthService(
        auth: mockAuth,
        dbService: mockDbService,
        logger: mockLogger,
      );
    });

    tearDown(() {
      authStreamController.close();
    });

    test('should be signed out initially', () {
      // Assert
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
    });

    test(
      'should sign in user and save user data when auth state changes',
      () async {
        // Act
        authStreamController.add(mockUser);

        await Future.delayed(Duration.zero);

        // Assert
        expect(authService.isSignedIn, isTrue);
        expect(authService.currentUser, mockUser);
        verify(() => mockDbService.saveUserData(mockUser)).called(1);
      },
    );

    test('should sign out user when auth state changes to null', () async {
      // Arrange
      authStreamController.add(mockUser);
      await Future.delayed(Duration.zero);
      expect(authService.isSignedIn, isTrue);

      // Act
      authStreamController.add(null);
      await Future.delayed(Duration.zero);

      // Assert
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
    });

    test(
      'should call signOut on FirebaseAuth when signOut is called',
      () async {
        // Act
        await authService.signOut();

        // Assert
        verify(() => mockAuth.signOut()).called(1);
      },
    );

    test('should log an error if saving user data fails', () async {
      // Arrange
      final exception = Exception('Database connection failed');
      when(() => mockDbService.saveUserData(any())).thenThrow(exception);

      // Act
      authStreamController.add(mockUser);
      await Future.delayed(Duration.zero);

      // Assert
      expect(authService.isSignedIn, isTrue);
      verify(
        () => mockLogger.e(
          'Error while storing user data',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });

    test('dispose should cancel the auth state subscription', () {
      // Arrange
      expect(authStreamController.hasListener, isTrue);

      // Act
      authService.dispose();

      // Assert
      expect(authStreamController.hasListener, isFalse);
    });
  });
}
