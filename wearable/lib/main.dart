import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'screens/barcode_page.dart';

Future<void> configureApp({
  required Logger logger,
  required bool isAndroid,
  required bool isDebug,
  FirebaseRemoteConfig? remoteConfig,
  FirebaseAppCheck? appCheck,
  FirebaseCrashlytics? crashlytics,
}) async {
  try {
    if (isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final remoteConfigInstance =
          remoteConfig ?? FirebaseRemoteConfig.instance;
      final appCheckInstance = appCheck ?? FirebaseAppCheck.instance;
      final crashlyticsInstance = crashlytics ?? FirebaseCrashlytics.instance;

      await remoteConfigInstance.fetchAndActivate();

      if (isDebug) {
        await appCheckInstance.activate(
          androidProvider: AndroidProvider.debug,
        );
      } else {
        await appCheckInstance.activate(
          androidProvider: AndroidProvider.playIntegrity,
        );
      }

      FlutterError.onError = (errorDetails) {
        crashlyticsInstance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        crashlyticsInstance.recordError(error, stack, fatal: true);
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

  await configureApp(
      logger: logger, isAndroid: Platform.isAndroid, isDebug: kDebugMode);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState.main()),
    ],
    child: const TaxCodeApp(),
  ));
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
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            brightness: Brightness.dark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
