import 'dart:async';

import 'package:logger/logger.dart';
import 'package:shared/models/app_failure.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/utils/tax_code_generator.dart';

export 'package:shared/models/app_failure.dart';

/// Contract for the TaxCodeService.
abstract interface class TaxCodeService {
  /// Fetches or computes the tax code for the specified identity data.
  Future<TaxCodeResponse> fetchTaxCode({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthPlaceName,
    required String birthPlaceState,
    required DateTime birthDate,
  });

  /// Factory constructor returning the default implementation.
  factory TaxCodeService({
    required BirthplaceService birthplaceService,
    required Logger logger,
  }) = DefaultTaxCodeService;
}

/// Backwards-compatible alias for [TaxCodeService].
typedef TaxCodeServiceAbstract = TaxCodeService;

/// Default implementation of [TaxCodeService].
/// This class is responsible for generating tax codes locally.
class DefaultTaxCodeService implements TaxCodeService {
  final BirthplaceService _birthplaceService;
  final Logger _logger;

  DefaultTaxCodeService({
    required BirthplaceService birthplaceService,
    required Logger logger,
  })  : _birthplaceService = birthplaceService,
        _logger = logger;

  @override
  Future<TaxCodeResponse> fetchTaxCode({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthPlaceName,
    required String birthPlaceState,
    required DateTime birthDate,
  }) async {
    try {
      final birthplaces = await _birthplaceService.loadBirthplaces();
      final birthplace = birthplaces.firstWhere(
        (b) =>
            b.name.toLowerCase() == birthPlaceName.toLowerCase() &&
            b.state.toLowerCase() == birthPlaceState.toLowerCase(),
        orElse: () => throw const BirthplaceNotFoundFailure(),
      );

      if (birthplace.code.isEmpty) {
        throw const MissingBirthplaceCodeFailure();
      }

      final fiscalCode = TaxCodeGenerator.generate(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: birthDate,
        gender: gender,
        birthplaceCode: birthplace.code,
      );

      return TaxCodeResponse(
        status: true,
        message: 'Calculated successfully',
        data: TaxCodeData(
          fiscalCode: fiscalCode,
        ),
      );
    } on TaxCodeApiServerException {
      rethrow;
    } on Object catch (e, s) {
      _logger.e('Unexpected error in TaxCodeService: $e', error: e, stackTrace: s);
      throw const CalculationFailure();
    }
  }
}
