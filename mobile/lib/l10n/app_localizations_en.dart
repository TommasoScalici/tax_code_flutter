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
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get info => 'Info';

  @override
  String get actionRequired => 'Action Required';

  @override
  String get requiresRecentLoginMessage =>
      'For security reasons, this operation requires recent authentication. Please log in again and retry.';

  @override
  String get pleaseSignIn => 'Welcome, please sign in to continue.';

  @override
  String get pleaseSignUp => 'Welcome, please create an account to continue.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'Are you sure you want to delete your account? All your data will be permanently lost. This action is irreversible.';

  @override
  String get homePageTitle => 'My Contacts';

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get formPageTitle => 'Contact Details';

  @override
  String get barcodePageTitle => 'Tax Code Barcode';

  @override
  String get takePicture => 'Scan Card';

  @override
  String get ocrFailedErrorMessage =>
      'Could not read data from the picture. Please try taking a new, more focused one.';

  @override
  String get newItem => 'Add Contact';

  @override
  String get invalidCharacters => 'The field contains invalid characters.';

  @override
  String get search => 'Search by name or tax code...';

  @override
  String get contactsListEmpty =>
      'No contacts yet.\nTap the \'+\' button to add your first one!';

  @override
  String searchNoResults(String searchText) {
    return 'No results found for \'$searchText\'';
  }

  @override
  String get tooltipShare => 'Share Tax Code';

  @override
  String get tooltipShowBarcode => 'Show Barcode';

  @override
  String get tooltipEdit => 'Edit Contact';

  @override
  String get tooltipDelete => 'Delete Contact';

  @override
  String get scanCard => 'Scan from Health Card';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get gender => 'Gender';

  @override
  String get birthDate => 'Date of Birth';

  @override
  String get birthPlace => 'Place of Birth';

  @override
  String get required => 'This field is required';

  @override
  String get deleteConfirmation => 'Confirm Deletion';

  @override
  String deleteMessage(String taxCode) {
    return 'Are you sure you want to permanently delete the contact for \'$taxCode\'?';
  }

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get cameraPermissionInfo =>
      'To scan cards, this app needs access to your camera. Please go to your device settings and grant camera permission.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get error => 'Error';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get tooltipToggleFlash => 'Toggle flash';

  @override
  String get tooltipTakePicture => 'Take picture';

  @override
  String get tooltipConfirmPicture => 'Confirm picture';

  @override
  String get tooltipRetakePicture => 'Retake picture';

  @override
  String get termsAndCondition =>
      'By proceeding, you agree to our Terms and Conditions.';

  @override
  String get showTerms => 'View Terms & Conditions';

  @override
  String get appName => 'App Name';

  @override
  String get packageName => 'Package Name';

  @override
  String get appVersion => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get buildSignature => 'Build Signature';

  @override
  String get installerStore => 'Installer Store';
}
