import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'settings.dart';

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

final class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        appState.loadTheme();

        return MaterialApp(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            FirebaseUILocalizations.delegate
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: appState.theme == 'dark'
              ? Settings.getDarkTheme()
              : Settings.getLightTheme(),
          home: const AuthGate(),
        );
      },
    );
  }
}
