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
  String get loginError => 'Login fallito. Riprova.';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String welcomeMessage(String appName) {
    return 'Benvenuto su $appName';
  }

  @override
  String get noContactsFoundMessage =>
      'Nessun contatto trovato.\nAggiungi un contatto dal tuo smartphone per visualizzarlo qui.';

  @override
  String get barcodePageTitle => 'Codice a Barre';
}
