import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/hive_registrar.g.dart';
import 'package:shared/utils/app_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter_wear_os/core/providers.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
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
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      final appCheckProvider = kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider();
      await FirebaseAppCheck.instance.activate(
        providerAndroid: appCheckProvider,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    },
  );

  runApp(
    MultiProvider(
      providers: getAppProviders(
        logger: logger,
        sharedPreferences: sharedPreferences,
      ),
      child: const TaxCodeApp(),
    ),
  );
}

class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: Settings.getWearTheme(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == null) return null;

    final uri = Uri.parse(settings.name!);

    switch (uri.path) {
      case '/barcode':
        final taxCode = uri.queryParameters['taxCode'];

        if (taxCode != null && taxCode.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => BarcodePage(taxCode: taxCode),
            settings: settings,
          );
        }
        break;
    }

    return MaterialPageRoute(builder: (_) => const AuthGate());
  }
}
