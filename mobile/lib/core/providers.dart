import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/gemini_service.dart';
import 'package:shared/services/hive_local_cache_service.dart';
import 'package:shared/services/local_cache_service.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

List<SingleChildWidget> getAppProviders({
  required Logger logger,
  required SharedPreferencesAsync sharedPreferences,
  required ReviewService reviewService,
}) {
  return [
    // --- Level 1: Low-level and External Instances ---
    Provider<Logger>.value(value: logger),
    Provider<GoogleSignIn>.value(value: GoogleSignIn()),
    Provider<SharedPreferencesAsync>.value(value: sharedPreferences),
    Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
    Provider<FirebaseCrashlytics>(create: (_) => FirebaseCrashlytics.instance),
    Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
    Provider<FirebaseFunctions>.value(
      value: FirebaseFunctions.instanceFor(region: 'us-central1'),
    ),
    Provider<FirebaseRemoteConfig>.value(value: FirebaseRemoteConfig.instance),

    // --- Level 2: Specialized, Self-Contained Services ---
    Provider<PermissionServiceAbstract>(
      create: (context) => PermissionService(
        logger: context.read<Logger>(),
        permissionHandler: AppPermissionHandlerAdapter(),
      ),
    ),
    Provider<CameraServiceAbstract>(
      create: (context) => CameraService(logger: context.read<Logger>()),
    ),
    Provider<DatabaseService>(
      create: (context) =>
          DatabaseService(firestore: context.read<FirebaseFirestore>()),
    ),
    Provider<BirthplaceServiceAbstract>(
      create: (context) => BirthplaceService(
        logger: context.read<Logger>(),
      ),
    ),
    Provider<InfoServiceAbstract>(
      create: (context) => InfoService(logger: context.read<Logger>()),
    ),
    Provider<BrightnessServiceAbstract>(
      create: (context) => BrightnessService(logger: context.read<Logger>()),
    ),
    Provider<SharingServiceAbstract>(
      create: (context) => SharingService(
        logger: context.read<Logger>(),
        shareAdapter: AppShareAdapter(),
      ),
    ),
    Provider<GeminiServiceAbstract>(
      create: (context) => GeminiService(
        functions: context.read<FirebaseFunctions>(),
        logger: context.read<Logger>(),
      ),
    ),
    Provider<TaxCodeServiceAbstract>(
      create: (context) => TaxCodeService(
        birthplaceService: context.read<BirthplaceServiceAbstract>(),
        logger: context.read<Logger>(),
      ),
    ),
    Provider<ReviewService>.value(value: reviewService),
    Provider<InAppReviewService>(
      create: (context) => InAppReviewService(
        reviewService: context.read<ReviewService>(),
        logger: context.read<Logger>(),
      ),
    ),

    // --- Level 3: State Services ---
    Provider<LocalCacheService>(create: (_) => HiveLocalCacheService()),
    ChangeNotifierProvider<ThemeService>(
      create: (context) =>
          ThemeService(prefs: context.read<SharedPreferencesAsync>())..init(),
    ),
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

    // --- Level 5: View Controllers ---
    ChangeNotifierProvider<HomePageController>(
      create: (context) => HomePageController(
        contactRepository: context.read<ContactRepository>(),
        sharingService: context.read<SharingServiceAbstract>(),
        birthplaceService: context.read<BirthplaceServiceAbstract>(),
      ),
    ),
  ];
}
