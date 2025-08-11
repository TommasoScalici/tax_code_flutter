import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'screens/barcode_page.dart';

Future<void> configureApp(Logger logger) async {
  try {
    if (Platform.isAndroid) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final appCheck = FirebaseAppCheck.instance;
      final crashlytics = FirebaseCrashlytics.instance;

      await remoteConfig.fetchAndActivate();

      final androidProvider =
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity;
      await appCheck.activate(androidProvider: androidProvider);

      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureApp(logger);

  final sharedPreferences = SharedPreferencesAsync();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  runApp(
    MultiProvider(
      providers: [
        Provider<Logger>.value(value: logger),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(firestore: firestore),
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(prefs: sharedPreferences)..init(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            auth: firebaseAuth,
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
        ),
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
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

class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/barcode') == true) {
      final uri = Uri.parse(settings.name!);
      final taxCode = uri.queryParameters['taxCode'];

      if (taxCode != null) {
        return MaterialPageRoute(
          builder: (context) => BarcodePage(taxCode: taxCode),
        );
      }
    }

    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(child: Text('Error: Invalid Route')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      onGenerateRoute: _onGenerateRoute,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0),
            brightness: themeService.theme == 'dark'
                ? Brightness.dark
                : Brightness.light),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
