// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Codice Fiscale';

  @override
  String get barcode1D => 'Codice a barre 1D';

  @override
  String get barcodePageTitle => 'Codice a Barre';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get loginError => 'Login fallito. Riprova.';

  @override
  String get logout => 'Esci';

  @override
  String get logoutConfirmation => 'Vuoi uscire dall\'account?';

  @override
  String get noContactsFoundMessage =>
      'Nessun contatto. Aggiungili dal telefono.';

  @override
  String get openOnPhone => 'Apri sul telefono';

  @override
  String get qrCode2D => 'QR Code';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get swipeToClose => 'Scorri a destra per chiudere';

  @override
  String get tapToSwitchBarcode => 'Tocca per passare a QR code';

  @override
  String welcomeMessage(String appName) {
    return 'Benvenuto su $appName';
  }
}
