import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/gemini_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

import 'mocks.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  MockAuthService? mockAuthService,
  MockLogger? mockLogger,
  MockThemeService? mockThemeService,
  MockContactRepository? mockContactRepository,
  MockBirthplaceService? mockBirthplaceService,
  MockTaxCodeService? mockTaxCodeService,
  MockInfoService? mockInfoService,
  MockCameraService? mockCameraService,
  MockGeminiService? mockGeminiService,
  MockPermissionService? mockPermissionService,
  AuthStatus? authStatus,
  Locale? locale,
}) async {
  final authService = mockAuthService ?? MockAuthService();
  final themeService = mockThemeService ?? MockThemeService();
  final logger = mockLogger ?? MockLogger();
  final cameraService = mockCameraService ?? MockCameraService();
  final geminiService = mockGeminiService ?? MockGeminiService();
  final permissionService = mockPermissionService ?? MockPermissionService();
  final contactRepository = mockContactRepository ?? MockContactRepository();
  final birthplaceService = mockBirthplaceService ?? MockBirthplaceService();
  final taxCodeService = mockTaxCodeService ?? MockTaxCodeService();
  final infoService = mockInfoService ?? MockInfoService();
  final googleSignIn = MockGoogleSignIn();
  final sharedPreferences = MockSharedPreferences();
  final firebaseAuth = MockFirebaseAuth();
  final firebaseCrashlytics = MockFirebaseCrashlytics();
  final firebaseFirestore = MockFirebaseFirestore();
  final firebaseFunctions = MockFirebaseFunctions();
  final remoteConfig = MockFirebaseRemoteConfig();
  final databaseService = MockDatabaseService();
  final brightnessService = MockBrightnessService();
  final sharingService = MockSharingService();

  final currentStatus = authStatus ?? AuthStatus.unauthenticated;
  if (mockAuthService == null) {
    when(() => authService.status).thenReturn(currentStatus);
    when(
      () => authService.isSignedIn,
    ).thenReturn(currentStatus == AuthStatus.authenticated);
    when(() => authService.isGuest).thenReturn(false);
  } else {
    if (authStatus != null) {
      when(() => authService.status).thenReturn(authStatus);
    }
    try {
      authService.isGuest;
    } on Object catch (_) {
      when(() => authService.isGuest).thenReturn(false);
    }
    try {
      authService.isSignedIn;
    } on Object catch (_) {
      when(
        () => authService.isSignedIn,
      ).thenReturn(currentStatus == AuthStatus.authenticated);
    }
  }

  when(birthplaceService.loadBirthplaces).thenAnswer((_) async => []);
  when(() => contactRepository.addListener(any())).thenReturn(null);
  when(() => contactRepository.removeListener(any())).thenReturn(null);
  if (mockContactRepository == null) {
    when(() => contactRepository.isLoading).thenReturn(false);
    when(() => contactRepository.contacts).thenReturn(<Contact>[]);
  }

  when(() => themeService.theme).thenReturn(AppThemeMode.light);
  when(() => remoteConfig.getString(any<String>())).thenReturn('');

  when(
    () => logger.e(
      any<Object?>(),
      error: any<Object?>(named: 'error'),
      stackTrace: any<StackTrace?>(named: 'stackTrace'),
    ),
  ).thenAnswer((_) {});

  when(permissionService.requestCameraPermission).thenAnswer((_) async => true);
  when(permissionService.openAppSettingsHandler).thenAnswer((_) async => true);

  when(infoService.getPackageInfo).thenAnswer(
    (_) async => PackageInfo(
      appName: 'Test App',
      packageName: 'com.test.app',
      version: '1.0.0-test',
      buildNumber: '99',
    ),
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        // --- Level 1: Low-level and External Instances ---
        Provider<Logger>.value(value: logger),
        Provider<GoogleSignIn>.value(value: googleSignIn),
        Provider<SharedPreferencesAsync>.value(value: sharedPreferences),
        Provider<FirebaseAuth>.value(value: firebaseAuth),
        Provider<FirebaseCrashlytics>.value(value: firebaseCrashlytics),
        Provider<FirebaseFirestore>.value(value: firebaseFirestore),
        Provider<FirebaseFunctions>.value(value: firebaseFunctions),
        Provider<FirebaseRemoteConfig>.value(value: remoteConfig),

        // --- Level 2: Specialized, Self-Contained Services ---
        Provider<PermissionServiceAbstract>.value(value: permissionService),
        Provider<CameraServiceAbstract>.value(value: cameraService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<BirthplaceServiceAbstract>.value(value: birthplaceService),
        Provider<InfoServiceAbstract>.value(value: infoService),
        Provider<BrightnessServiceAbstract>.value(value: brightnessService),
        Provider<SharingServiceAbstract>.value(value: sharingService),
        Provider<GeminiServiceAbstract>.value(value: geminiService),
        Provider<TaxCodeServiceAbstract>.value(value: taxCodeService),

        // --- Level 3: State Services ---
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        ChangeNotifierProvider<AuthService>.value(value: authService),

        // --- Level 4: Repositories ---
        ChangeNotifierProvider<ContactRepository>.value(
          value: contactRepository,
        ),

        // --- Level 5: View Controllers ---
        ChangeNotifierProvider<HomePageController>(
          create: (_) => HomePageController(
            contactRepository: contactRepository,
            sharingService: sharingService,
            birthplaceService: birthplaceService,
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // MaterialUiCompatibilityBridge is deprecated by Flutter to denote temporary migration utility.
        // ignore: deprecated_member_use
        builder: (context, child) => MaterialUiCompatibilityBridge(
          child: legacy.Material(
            type: legacy.MaterialType.transparency,
            child: child,
          ),
        ),
        home: widget,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
