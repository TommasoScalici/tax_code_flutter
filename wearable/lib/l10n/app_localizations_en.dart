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
  String get loginError => 'Login failed. Please try again.';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String welcomeMessage(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get noContactsFoundMessage =>
      'No contacts found.\nPlease add a contact on your phone to see it here.';

  @override
  String get barcodePageTitle => 'Tax Code Barcode';
}
