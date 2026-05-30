import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/hive_local_cache_service.dart';
import 'package:shared/services/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

List<SingleChildWidget> getAppProviders({
  required Logger logger,
  required SharedPreferencesAsync sharedPreferences,
}) {
  return [
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
    Provider<LocalCacheService>(
      create: (_) => HiveLocalCacheService(),
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
    ChangeNotifierProvider<ContactRepository>(
      create: (context) => ContactRepository(
        authService: context.read<AuthService>(),
        dbService: context.read<DatabaseService>(),
        cacheService: context.read<LocalCacheService>(),
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
  ];
}
