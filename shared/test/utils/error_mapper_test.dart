import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/app_failure.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/utils/error_mapper.dart';

void main() {
  group('ErrorMapper fromException', () {
    test('maps AppFailure directly to itself', () {
      const failure = BirthplaceNotFoundFailure();
      expect(ErrorMapper.fromException(failure), isA<BirthplaceNotFoundFailure>());
    });

    test('maps TaxCodeApiNetworkException to NetworkFailure', () {
      const exception = TaxCodeApiNetworkException();
      expect(ErrorMapper.fromException(exception), isA<NetworkFailure>());
    });

    test('maps TaxCodeApiServerException birthplace-not-found to BirthplaceNotFoundFailure', () {
      const exception = TaxCodeApiServerException('birthplace-not-found');
      expect(ErrorMapper.fromException(exception), isA<BirthplaceNotFoundFailure>());
    });

    test('maps TaxCodeApiServerException missing-birthplace-code to MissingBirthplaceCodeFailure', () {
      const exception = TaxCodeApiServerException('missing-birthplace-code');
      expect(ErrorMapper.fromException(exception), isA<MissingBirthplaceCodeFailure>());
    });

    test('maps TaxCodeApiServerException calculation-failed to CalculationFailure', () {
      const exception = TaxCodeApiServerException('calculation-failed');
      expect(ErrorMapper.fromException(exception), isA<CalculationFailure>());
    });

    test('maps TaxCodeApiServerException resource-exhausted to RateLimitFailure', () {
      const exception = TaxCodeApiServerException('resource-exhausted');
      expect(ErrorMapper.fromException(exception), isA<RateLimitFailure>());
    });

    test('maps TaxCodeApiServerException unauthenticated to SessionExpiredFailure', () {
      const exception = TaxCodeApiServerException('unauthenticated');
      expect(ErrorMapper.fromException(exception), isA<SessionExpiredFailure>());
    });

    test('maps TaxCodeApiServerException deadline-exceeded to DeadlineExceededFailure', () {
      const exception = TaxCodeApiServerException('deadline-exceeded');
      expect(ErrorMapper.fromException(exception), isA<DeadlineExceededFailure>());
    });

    test('maps TaxCodeApiServerException unavailable to ServiceUnavailableFailure', () {
      const exception = TaxCodeApiServerException('unavailable');
      expect(ErrorMapper.fromException(exception), isA<ServiceUnavailableFailure>());
    });

    test('maps unknown TaxCodeApiServerException to ServiceUnavailableFailure', () {
      const exception = TaxCodeApiServerException('unknown-code');
      expect(ErrorMapper.fromException(exception), isA<ServiceUnavailableFailure>());
    });

    test('maps generic Exception to GenericFailure', () {
      final exception = Exception('unexpected');
      expect(ErrorMapper.fromException(exception), isA<GenericFailure>());
    });
  });

  group('ErrorMapper toKey and fromKey', () {
    test('maps each AppFailure to its semantic key correctly', () {
      expect(const BirthplaceNotFoundFailure().toKey(), 'birthplaceNotFound');
      expect(const MissingBirthplaceCodeFailure().toKey(), 'missingBirthplaceCode');
      expect(const CalculationFailure().toKey(), 'calculationFailed');
      expect(const NetworkFailure().toKey(), 'networkError');
      expect(const RateLimitFailure().toKey(), 'rateLimitExceeded');
      expect(const SessionExpiredFailure().toKey(), 'sessionExpired');
      expect(const ServiceUnavailableFailure().toKey(), 'serviceUnavailable');
      expect(const DeadlineExceededFailure().toKey(), 'deadlineExceeded');
      expect(const SignInFailedFailure().toKey(), 'signInFailed');
      expect(const ReauthFailedFailure().toKey(), 'reauthFailed');
      expect(const GenericFailure().toKey(), 'genericError');
    });

    test('parses keys back into correct AppFailure instances via fromKey', () {
      expect(ErrorMapper.fromKey('birthplaceNotFound'), isA<BirthplaceNotFoundFailure>());
      expect(ErrorMapper.fromKey('missingBirthplaceCode'), isA<MissingBirthplaceCodeFailure>());
      expect(ErrorMapper.fromKey('calculationFailed'), isA<CalculationFailure>());
      expect(ErrorMapper.fromKey('networkError'), isA<NetworkFailure>());
      expect(ErrorMapper.fromKey('rateLimitExceeded'), isA<RateLimitFailure>());
      expect(ErrorMapper.fromKey('sessionExpired'), isA<SessionExpiredFailure>());
      expect(ErrorMapper.fromKey('serviceUnavailable'), isA<ServiceUnavailableFailure>());
      expect(ErrorMapper.fromKey('deadlineExceeded'), isA<DeadlineExceededFailure>());
      expect(ErrorMapper.fromKey('signInFailed'), isA<SignInFailedFailure>());
      expect(ErrorMapper.fromKey('reauthFailed'), isA<ReauthFailedFailure>());
      expect(ErrorMapper.fromKey('unknown'), isA<GenericFailure>());
    });

    test('mapErrorToKey returns expected key for TaxCodeApiServerException', () {
      expect(
        ErrorMapper.mapErrorToKey(const BirthplaceNotFoundFailure()),
        'birthplaceNotFound',
      );
      expect(
        ErrorMapper.mapErrorToKey(const TaxCodeApiServerException('birthplace-not-found')),
        'birthplaceNotFound',
      );
      expect(
        ErrorMapper.mapErrorToKey(const TaxCodeApiServerException('resource-exhausted')),
        'rateLimitExceeded',
      );
    });
  });
}
