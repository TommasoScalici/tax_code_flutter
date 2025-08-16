import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/card_parser_service.dart';
import 'package:tax_code_flutter/services/google_vision_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/ocr_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'settings.dart';

/// Configures Firebase services like Remote Config, AppCheck, and Crashlytics.
Future<void> configureApp(Logger logger) async {
  try {
    if (Platform.isAndroid) {
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      final appCheckProvider =
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity;
      await FirebaseAppCheck.instance.activate(androidProvider: appCheckProvider);

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } on Exception catch (e, s) {
    logger.e('Error while configuring the app with Firebase', error: e, stackTrace: s);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final logger = Logger();
  final sharedPreferences = SharedPreferencesAsync();
  await configureApp(logger);

  runApp(
    MultiProvider(
      providers: [
        // --- Level 1: Low-level and External Instances ---
        Provider<Logger>.value(value: logger),
        Provider<SharedPreferencesAsync>.value(value: sharedPreferences),
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
        Provider<FirebaseRemoteConfig>.value(value: FirebaseRemoteConfig.instance),
        Provider<GoogleSignIn>.value(value: GoogleSignIn()),
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<FirebaseCrashlytics>(create: (_) => FirebaseCrashlytics.instance),

        // --- Level 2: Specialized, Self-Contained Services ---
        Provider<DatabaseService>(
          create: (context) => DatabaseService(firestore: context.read<FirebaseFirestore>()),
        ),
        Provider<BirthplaceServiceAbstract>(
          create: (context) => BirthplaceService(logger: context.read<Logger>()),
        ),
        Provider<InfoServiceAbstract>(
          create: (context) => InfoService(logger: context.read<Logger>()),
        ),
        Provider<BrightnessServiceAbstract>(
          create: (context) => BrightnessService(logger: context.read<Logger>()),
        ),
        Provider<SharingServiceAbstract>(
          create: (context) => SharingService(logger: context.read<Logger>()),
        ),
        Provider<GoogleVisionServiceAbstract>(
          create: (context) => GoogleVisionService(
            remoteConfig: context.read<FirebaseRemoteConfig>(),
            logger: context.read<Logger>(),
          ),
        ),
        Provider<CardParserServiceAbstract>(
          create: (_) => CardParserService(),
        ),
        Provider<TaxCodeServiceAbstract>(
          create: (context) {
            final remoteConfig = context.read<FirebaseRemoteConfig>();
            final accessToken = remoteConfig.getString(Settings.mioCodiceFiscaleApiKey);
            return TaxCodeService(
              client: context.read<http.Client>(),
              logger: context.read<Logger>(),
              accessToken: accessToken,
            );
          },
        ),
        Provider<OCRServiceAbstract>(
          create: (context) => OCRService(
            visionService: context.read<GoogleVisionServiceAbstract>(),
            parserService: context.read<CardParserServiceAbstract>(),
            logger: context.read<Logger>(),
          ),
        ),

        // --- Level 3: State Services ---
        ChangeNotifierProvider<ThemeService>(
          create: (context) => ThemeService(prefs: context.read<SharedPreferencesAsync>())..init(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            auth: context.read<FirebaseAuth>(),
            googleSignIn: context.read<GoogleSignIn>(),
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
        ),

        // --- Level 4: Repositories ---
        ChangeNotifierProxyProvider<AuthService, ContactRepository>(
          create: (context) => ContactRepository(
            authService: context.read<AuthService>(),
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
          update: (context, authService, previousRepository) => previousRepository!,
        ),

        // --- Level 5: View Controllers ---
        ChangeNotifierProvider<HomePageController>(
          create: (context) => HomePageController(
            contactRepository: context.read<ContactRepository>(),
            sharingService: context.read<SharingServiceAbstract>(),
          ),
        ),
      ],
      child: const TaxCodeApp(),
    ),
  );
}

/// The root widget of the application.
final class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FirebaseUILocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: themeService.theme == 'dark'
          ? Settings.getDarkTheme()
          : Settings.getLightTheme(),
      home: const AuthGate(),
    );
  }
}