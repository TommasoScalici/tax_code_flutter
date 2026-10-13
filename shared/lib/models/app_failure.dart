/// Represents domain, operational, and application-level failures
/// in a type-safe, exhaustive sealed hierarchy.
sealed class AppFailure implements Exception {
  const AppFailure();

  /// Converts this failure to a semantic string key (for backward compatibility and logging).
  String toKey() => switch (this) {
    BirthplaceNotFoundFailure() => 'birthplaceNotFound',
    MissingBirthplaceCodeFailure() => 'missingBirthplaceCode',
    CalculationFailure() => 'calculationFailed',
    NetworkFailure() => 'networkError',
    RateLimitFailure() => 'rateLimitExceeded',
    SessionExpiredFailure() => 'sessionExpired',
    ServiceUnavailableFailure() => 'serviceUnavailable',
    DeadlineExceededFailure() => 'deadlineExceeded',
    SignInFailedFailure() => 'signInFailed',
    ReauthFailedFailure() => 'reauthFailed',
    TaxCodeApiServerException(:final code) => switch (code) {
      'birthplace-not-found' => 'birthplaceNotFound',
      'missing-birthplace-code' => 'missingBirthplaceCode',
      'calculation-failed' => 'calculationFailed',
      'resource-exhausted' => 'rateLimitExceeded',
      'unauthenticated' || 'permission-denied' => 'sessionExpired',
      'deadline-exceeded' => 'deadlineExceeded',
      'unavailable' || 'failed-precondition' => 'serviceUnavailable',
      _ => 'genericError',
    },
    GenericFailure() => 'genericError',
  };
}

/// Server or API error for tax code calculations, maintaining backward
/// compatibility with legacy code catching [TaxCodeApiServerException].
class TaxCodeApiServerException extends AppFailure {
  final String code;
  const TaxCodeApiServerException(this.code);

  @override
  String toString() => 'TaxCodeApiServerException: $code';
}

/// Thrown or emitted when the specified birthplace municipality or country
/// cannot be found in the database.
final class BirthplaceNotFoundFailure extends TaxCodeApiServerException {
  const BirthplaceNotFoundFailure() : super('birthplace-not-found');

  @override
  String toString() =>
      'BirthplaceNotFoundFailure: Birthplace not found in database.';
}

/// Thrown or emitted when the selected birthplace does not have a valid
/// 4-character Belfiore cadastral code.
final class MissingBirthplaceCodeFailure extends TaxCodeApiServerException {
  const MissingBirthplaceCodeFailure() : super('missing-birthplace-code');

  @override
  String toString() =>
      'MissingBirthplaceCodeFailure: Missing Belfiore code for birthplace.';
}

/// Thrown or emitted when local tax code generation encounters inconsistent or invalid data.
final class CalculationFailure extends TaxCodeApiServerException {
  const CalculationFailure() : super('calculation-failed');

  @override
  String toString() => 'CalculationFailure: Tax code generation failed.';
}

/// Thrown or emitted when an operation fails due to missing or interrupted network connectivity.
class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  String toString() => 'NetworkFailure: No internet connection.';
}

/// Legacy alias for [NetworkFailure].
class TaxCodeApiNetworkException extends NetworkFailure {
  const TaxCodeApiNetworkException();
}

/// Thrown or emitted when API quota or rate limits have been exceeded.
final class RateLimitFailure extends AppFailure {
  const RateLimitFailure();

  @override
  String toString() =>
      'RateLimitFailure: Request quota or rate limit exceeded.';
}

/// Thrown or emitted when authentication credentials or user session have expired.
final class SessionExpiredFailure extends AppFailure {
  const SessionExpiredFailure();

  @override
  String toString() =>
      'SessionExpiredFailure: Session has expired. Please sign in again.';
}

/// Thrown or emitted when remote cloud services are temporarily unavailable or down.
final class ServiceUnavailableFailure extends AppFailure {
  const ServiceUnavailableFailure();

  @override
  String toString() =>
      'ServiceUnavailableFailure: Remote service is unavailable.';
}

/// Thrown or emitted when an operation times out waiting for a remote response.
final class DeadlineExceededFailure extends AppFailure {
  const DeadlineExceededFailure();

  @override
  String toString() =>
      'DeadlineExceededFailure: Operation deadline was exceeded.';
}

/// Thrown or emitted when an interactive or anonymous authentication attempt fails.
final class SignInFailedFailure extends AppFailure {
  const SignInFailedFailure();

  @override
  String toString() => 'SignInFailedFailure: Authentication attempt failed.';
}

/// Thrown or emitted when re-authentication fails or is cancelled during sensitive operations.
final class ReauthFailedFailure extends AppFailure {
  const ReauthFailedFailure();

  @override
  String toString() =>
      'ReauthFailedFailure: Re-authentication cancelled or failed.';
}

/// Catch-all failure for unmapped or generic exceptions.
final class GenericFailure extends AppFailure {
  final Object? cause;

  const GenericFailure([this.cause]);

  @override
  String toString() => 'GenericFailure: ${cause ?? 'Unknown error occurred.'}';
}
