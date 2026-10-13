import 'package:shared/models/app_failure.dart';
import 'package:shared/services/tax_code_service.dart';

class ErrorMapper {
  /// Converts an arbitrary exception or error into an [AppFailure].
  static AppFailure fromException(Object error) {
    if (error is TaxCodeApiNetworkException) {
      return const NetworkFailure();
    }
    if (error is TaxCodeApiServerException) {
      if (error is BirthplaceNotFoundFailure ||
          error is MissingBirthplaceCodeFailure ||
          error is CalculationFailure) {
        return error;
      }
      return switch (error.code) {
        'birthplace-not-found' => const BirthplaceNotFoundFailure(),
        'missing-birthplace-code' => const MissingBirthplaceCodeFailure(),
        'calculation-failed' => const CalculationFailure(),
        'resource-exhausted' => const RateLimitFailure(),
        'unauthenticated' ||
        'permission-denied' => const SessionExpiredFailure(),
        'deadline-exceeded' => const DeadlineExceededFailure(),
        'unavailable' ||
        'failed-precondition' => const ServiceUnavailableFailure(),
        _ => const ServiceUnavailableFailure(),
      };
    }
    if (error is AppFailure) {
      return error;
    }
    return GenericFailure(error);
  }

  /// Maps an exception from the Tax Code API (or general exception) to a localizable error key string.
  /// Maintained for backwards compatibility.
  static String mapErrorToKey(Object error) {
    return fromException(error).toKey();
  }

  /// Parses a legacy error key string into the corresponding [AppFailure].
  static AppFailure fromKey(String? key) {
    return switch (key) {
      'birthplaceNotFound' => const BirthplaceNotFoundFailure(),
      'missingBirthplaceCode' => const MissingBirthplaceCodeFailure(),
      'calculationFailed' => const CalculationFailure(),
      'networkError' => const NetworkFailure(),
      'rateLimitExceeded' => const RateLimitFailure(),
      'sessionExpired' => const SessionExpiredFailure(),
      'serviceUnavailable' => const ServiceUnavailableFailure(),
      'deadlineExceeded' => const DeadlineExceededFailure(),
      'signInFailed' => const SignInFailedFailure(),
      'reauthFailed' => const ReauthFailedFailure(),
      _ => const GenericFailure(),
    };
  }
}
