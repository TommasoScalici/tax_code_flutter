import 'package:shared/services/tax_code_service.dart';

class ErrorMapper {
  /// Maps an exception from the Tax Code API (or general exception) to a localizable error key string.
  static String mapErrorToKey(Object error) {
    if (error is TaxCodeApiNetworkException) {
      return 'networkError';
    } else if (error is TaxCodeApiServerException) {
      switch (error.code) {
        case 'resource-exhausted':
          return 'rateLimitExceeded';
        case 'unauthenticated':
        case 'permission-denied':
          return 'sessionExpired';
        case 'deadline-exceeded':
          return 'deadlineExceeded';
        case 'unavailable':
        case 'failed-precondition':
          return 'serviceUnavailable';
        default:
          return 'serviceUnavailable';
      }
    }
    return 'genericError';
  }
}
