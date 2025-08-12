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
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'settings.dart';

// AGGIUNTA: Funzione per una configurazione pulita
Future<void> configureApp(Logger logger) async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      final appCheckProvider = kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity;
      await FirebaseAppCheck.instance.activate(androidProvider: appCheckProvider);

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } on Exception catch (e) {
    logger.e('Error while configuring the app with Firebase: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  // Inizializzazione di base
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureApp(logger);

  final sharedPreferences = SharedPreferencesAsync();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();

  runApp(
    // MODIFICATO: Setup completo dei provider per la nuova architettura
    MultiProvider(
      providers: [
        // Servizi di base
        Provider<Logger>.value(value: logger),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(firestore: firestore),
        ),

        // Servizi con stato (ChangeNotifier)
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(prefs: sharedPreferences)..init(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            auth: firebaseAuth,
            googleSignIn: googleSignIn,
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
        ),
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),

        // Provider che dipende da un altro ChangeNotifier
        ChangeNotifierProxyProvider<AuthService, ContactRepository>(
          create: (context) => ContactRepository(
            authService: context.read<AuthService>(),
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
          update: (_, authService, previousRepo) => previousRepo!,
        ),
      ],
      child: const TaxCodeApp(),
    ),
  );
}

final class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MODIFICATO: Ascoltiamo solo il ThemeService, di cui abbiamo bisogno qui
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FirebaseUILocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // MODIFICATO: Il tema dipende da ThemeService, non più dal vecchio AppState
      theme: themeService.theme == 'dark'
          ? Settings.getDarkTheme()
          : Settings.getLightTheme(),
      home: const AuthGate(),
    );
  }
}