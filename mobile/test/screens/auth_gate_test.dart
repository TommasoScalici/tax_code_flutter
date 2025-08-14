import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';
import 'package:tax_code_flutter/screens/auth_gate.dart';
import 'package:tax_code_flutter/screens/home_page.dart';
import 'package:tax_code_flutter/settings.dart';

import '../utils/firebase_mock.dart';


// Mocks
class MockAuthService extends Mock implements AuthService {}
class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}
class MockThemeService extends Mock implements ThemeService {}
class MockContactRepository extends Mock implements ContactRepository {}
class MockAppState extends Mock implements AppState {}

void main() {
  setupFirebaseMocks();

  late MockAuthService mockAuthService;
  late MockFirebaseRemoteConfig mockRemoteConfig;
  late MockThemeService mockThemeService;
  late MockContactRepository mockContactRepository;
  late MockAppState mockAppState;

  setUp(() {
    mockAuthService = MockAuthService();
    mockRemoteConfig = MockFirebaseRemoteConfig();
    mockThemeService = MockThemeService();
    mockContactRepository = MockContactRepository();
    mockAppState = MockAppState();

    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.isSignedIn).thenReturn(false);
    when(() => mockRemoteConfig.getString(any())).thenReturn('fake_client_id');
    when(() => mockThemeService.theme).thenReturn('light');
    
    when(() => mockContactRepository.contacts).thenReturn([]);
    when(() => mockContactRepository.isLoading).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        Provider<FirebaseRemoteConfig>.value(value: mockRemoteConfig),
        ChangeNotifierProvider<ThemeService>.value(value: mockThemeService),
        ChangeNotifierProvider<ContactRepository>.value(value: mockContactRepository),
        ChangeNotifierProvider<AppState>.value(value: mockAppState),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthGate(),
      ),
    );
  }

  group('AuthGate', () {
    testWidgets('displays HomePage when user is signed in', (tester) async {
      when(() => mockAuthService.isSignedIn).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SignInScreen), findsNothing);
    });

    testWidgets('displays SignInScreen when user is not signed in', (tester) async {
      when(() => mockAuthService.isSignedIn).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      verify(() => mockRemoteConfig.getString(Settings.googleProviderClientId)).called(1);
    });
  });
}