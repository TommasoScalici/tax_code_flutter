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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
        );
      } else {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
        );
      }

      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } on Exception catch (e) {
    logger.e('Error while configuring the app with Firebase: $e');
  }

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
      home: AuthGate(),
    );
  }
}
