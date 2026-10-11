import 'package:shared/models/app_failure.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

export 'package:shared/models/app_failure.dart';

/// Extension on [AppFailure] providing exhaustive compile-time checked
/// translation to localized UI strings.
extension AppFailureLocalization on AppFailure {
  /// Resolves the localized error message using [AppLocalizations].
  String toLocalizedMessage(AppLocalizations l10n) => switch (this) {
    BirthplaceNotFoundFailure() => l10n.birthplaceNotFound,
    MissingBirthplaceCodeFailure() => l10n.missingBirthplaceCode,
    CalculationFailure() => l10n.calculationFailed,
    NetworkFailure() => l10n.networkError,
    RateLimitFailure() => l10n.rateLimitExceeded,
    SessionExpiredFailure() => l10n.sessionExpired,
    ServiceUnavailableFailure() => l10n.serviceUnavailable,
    DeadlineExceededFailure() => l10n.deadlineExceeded,
    SignInFailedFailure() => l10n.signInFailed,
    ReauthFailedFailure() => l10n.reauthFailed,
    TaxCodeApiServerException(:final code) => switch (code) {
      'birthplace-not-found' => l10n.birthplaceNotFound,
      'missing-birthplace-code' => l10n.missingBirthplaceCode,
      'calculation-failed' => l10n.calculationFailed,
      'resource-exhausted' => l10n.rateLimitExceeded,
      'unauthenticated' || 'permission-denied' => l10n.sessionExpired,
      'deadline-exceeded' => l10n.deadlineExceeded,
      _ => l10n.serviceUnavailable,
    },
    GenericFailure() => l10n.genericError,
  };
}
