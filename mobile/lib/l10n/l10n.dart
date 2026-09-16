import 'package:flutter/widgets.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_en.dart';

export 'package:tax_code_flutter/l10n/app_localizations.dart';
export 'package:tax_code_flutter/l10n/app_localizations_en.dart';
export 'package:tax_code_flutter/l10n/app_localizations_it.dart';

/// Extension on [BuildContext] providing streamlined, safe access to [AppLocalizations].
extension AppLocalizationsX on BuildContext {
  /// Returns the current [AppLocalizations] from the widget tree,
  /// or falls back to [AppLocalizationsEn] if called outside a localized subtree.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
