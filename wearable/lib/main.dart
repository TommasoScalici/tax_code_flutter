import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'settings.dart';

/// Configures Firebase services like Remote Config, AppCheck, and Crashlytics.
Future<void> configureApp(Logger logger) async {
  try {
    await FirebaseRemoteConfig.instance.fetchAndActivate();

    final appCheckProvider = kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity;
    await FirebaseAppCheck.instance.activate(androidProvider: appCheckProvider);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } on Exception catch (e, s) {
    logger.e(
      'Error while configuring the app with Firebase',
      error: e,
      stackTrace: s,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(BirthplaceAdapter());
  Hive.registerAdapter(ContactAdapter());

  final logger = Logger();
  final sharedPreferences = SharedPreferencesAsync();
  await configureApp(logger);

  runApp(
    MultiProvider(
      providers: [
        // --- Level 1: Low level and external instances ---
        Provider<Logger>.value(value: logger),
        Provider<SharedPreferencesAsync>.value(value: sharedPreferences),
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
        Provider<GoogleSignIn>.value(value: GoogleSignIn()),

        // --- Level 2: Services ---
        Provider<DatabaseService>(
          create: (context) =>
              DatabaseService(firestore: context.read<FirebaseFirestore>()),
        ),
        Provider<NativeViewServiceAbstract>(
          create: (context) =>
              NativeViewService(logger: context.read<Logger>()),
        ),

        // --- Level 3: State Services ---
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
          update: (context, authService, previousRepo) => ContactRepository(
            authService: authService,
            dbService: context.read<DatabaseService>(),
            logger: context.read<Logger>(),
          ),
        ),

        // --- Level 5: Controllers ---
        ChangeNotifierProvider<ContactsListController>(
          create: (context) => ContactsListController(
            contactRepository: context.read<ContactRepository>(),
            nativeViewService: context.read<NativeViewServiceAbstract>(),
            logger: context.read<Logger>(),
          ),
        ),
      ],
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
