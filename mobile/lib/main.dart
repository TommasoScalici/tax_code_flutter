import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/hive_registrar.g.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared/utils/app_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/core/providers.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/routes.dart';

import 'firebase_options.dart';
import 'settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapters();

  final logger = Logger();
  final sharedPreferences = SharedPreferencesAsync();
  await configureApp(
    logger: logger,
    configure: () async {
      await FirebaseRemoteConfig.instance.activate();
      unawaited(
        FirebaseRemoteConfig.instance.fetchAndActivate().catchError((Object e, StackTrace s) {
          logger.e(
            'Failed to fetch/activate remote config',
            error: e,
            stackTrace: s,
          );
          return false;
        }),
      );

      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
        );
        return true;
      };
    },
  );

  final reviewService = ReviewService(prefs: sharedPreferences);
  unawaited(
    Future.wait([
      reviewService.recordFirstLaunchIfNeeded(),
      reviewService.incrementAppOpenCount(),
    ]).catchError((Object e, StackTrace s) {
      logger.e(
        'Failed to update review service metrics',
        error: e,
        stackTrace: s,
      );
      return const <void>[];
    }),
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: getAppProviders(
        logger: logger,
        sharedPreferences: sharedPreferences,
        reviewService: reviewService,
      ),
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
        FirebaseUILocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: themeService.theme == ThemeMode.dark
          ? Settings.getDarkTheme()
          : Settings.getLightTheme(),
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.home,
    );
  }
}
