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
  String get loginError => 'Unexpected login error';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get noContactsFoundMessage =>
      'No contacts found, you must add one first from your smartphone to see here the list.';
}
