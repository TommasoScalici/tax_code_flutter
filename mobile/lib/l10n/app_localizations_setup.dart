import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

export 'package:tax_code_flutter/l10n/app_localizations.dart';

/// Centralized localization configuration providing both app strings and
/// modern Material UI localization delegates.
abstract final class AppLocalizationsSetup {
  /// All localization delegates including [AppLocalizations] and [GlobalMaterialLocalizations].
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    ...AppLocalizations.localizationsDelegates,
    ...GlobalMaterialLocalizations.delegates,
  ];

  /// Supported application locales.
  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;
}
