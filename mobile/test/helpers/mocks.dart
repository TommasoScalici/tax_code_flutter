import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/camera_service.dart';
import 'package:tax_code_flutter/services/gemini_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/permission_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockThemeService extends Mock implements ThemeService {}

class MockHomePageController extends Mock implements HomePageController {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockHttpClient extends Mock implements http.Client {}

class MockLogger extends Mock implements Logger {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockSharedPreferences extends Mock implements SharedPreferencesAsync {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

class MockPermissionService extends Mock implements PermissionServiceAbstract {}

class MockCameraService extends Mock implements CameraServiceAbstract {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockBirthplaceService extends Mock implements BirthplaceServiceAbstract {}

class MockInfoService extends Mock implements InfoServiceAbstract {}

class MockBrightnessService extends Mock implements BrightnessServiceAbstract {}

class MockSharingService extends Mock implements SharingServiceAbstract {}

class MockGeminiService extends Mock implements GeminiServiceAbstract {}

class MockTaxCodeService extends Mock implements TaxCodeServiceAbstract {}

class MockUser extends Mock implements User {}

class MockCameraController extends Mock implements CameraController {}

class FakeCameraDescription extends Fake implements CameraDescription {}
