import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseRemoteConfig.instance.fetchAndActivate();
  }

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => AppState())],
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
