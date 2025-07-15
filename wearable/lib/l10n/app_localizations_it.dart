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
  String get loginError => 'Errore durante il login';

  @override
  String get welcomeTo => 'Benvenuto su';

  @override
  String get noContactsFoundMessage =>
      'Nessun contatto trovato, aggiungi prima un contatto da smartphone per visualizzare qui la lista.';
}
