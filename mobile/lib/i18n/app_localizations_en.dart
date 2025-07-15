// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tax Code';

  @override
  String get pleaseSignIn => 'Welcome to Tax Code, please sign in.';

  @override
  String get pleaseSignUp => 'Welcome to Tax Code, please sign up.';

  @override
  String get termsAndCondition =>
      'By signing in/up, you agree to our terms and conditions.';

  @override
  String get showTerms => 'Show terms and conditions';

  @override
  String get required => 'Required';

  @override
  String get newItem => 'New';

  @override
  String get fillData => 'Fill data';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get gender => 'Gender';

  @override
  String get birthDate => 'Birth date';

  @override
  String get birthPlace => 'Birth place';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteConfirmation => 'Delete confirmation';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get signOut => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get info => 'Info';

  @override
  String get error => 'Error';

  @override
  String get errorLoading => 'Error occurred while loading contacts: ';

  @override
  String get search => 'Search...';

  @override
  String get scanCard => 'Scan card';

  @override
  String get takePicture => 'Take a picture...';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cameraPermissionInfo =>
      'The camera permission has been permanently denied.\nGo to the app settings, open the Permissions section, and enable the camera permission.';

  @override
  String get appName => 'App name';

  @override
  String get packageName => 'Package name';

  @override
  String get appVersion => 'App version';

  @override
  String get buildNumber => 'Build number';

  @override
  String get buildSignature => 'Build signature';

  @override
  String get installerStore => 'Installer store';

  @override
  String get errorNoInternet =>
      'Poor or no Internet connection available, you need it for code calculation.';

  @override
  String get deleteAccountMessage =>
      'Are you sure? All your data will be permanently loss.';

  @override
  String deleteMessage(String taxCode) {
    return 'Are you sure you want to delete the contact with tax code \'$taxCode\'?';
  }
}
