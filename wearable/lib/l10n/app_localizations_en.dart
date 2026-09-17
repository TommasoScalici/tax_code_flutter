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
  String get barcode1D => 'Barcode 1D';

  @override
  String get barcodePageTitle => 'Tax Code Barcode';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get loginError => 'Login failed. Please try again.';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmation => 'Do you want to sign out?';

  @override
  String get noContactsFoundMessage =>
      'No contacts found. Add them on your phone.';

  @override
  String get openOnPhone => 'Open on phone';

  @override
  String get qrCode2D => 'QR Code';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get swipeToClose => 'Swipe right to close';

  @override
  String get tapToSwitchBarcode => 'Tap to toggle QR code';

  @override
  String welcomeMessage(String appName) {
    return 'Welcome to $appName';
  }
}
