import 'dart:async';

import 'package:logger/logger.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/utils/tax_code_generator.dart';

/// Exception for network errors during tax code fetching.
class TaxCodeApiNetworkException implements Exception {}

/// Exception for server errors during tax code fetching.
class TaxCodeApiServerException implements Exception {
  final String code;
  TaxCodeApiServerException(this.code);
}

/// Abstract class for the TaxCodeService.
abstract class TaxCodeServiceAbstract {
  Future<TaxCodeResponse> fetchTaxCode({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthPlaceName,
    required String birthPlaceState,
    required DateTime birthDate,
  });
}

/// Implementation of the TaxCodeService.
/// This class is responsible for generating tax codes locally.
class TaxCodeService implements TaxCodeServiceAbstract {
  final BirthplaceServiceAbstract _birthplaceService;
  final Logger _logger;

  TaxCodeService({
    required BirthplaceServiceAbstract birthplaceService,
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
        orElse: () => throw TaxCodeApiServerException('birthplace-not-found'),
      );

      if (birthplace.code.isEmpty) {
        throw TaxCodeApiServerException('missing-birthplace-code');
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
        data: Data(
          fiscalCode: fiscalCode,
          allFiscalCodes: [fiscalCode],
        ),
      );
    } on TaxCodeApiServerException {
      rethrow;
    } catch (e, s) {
      _logger.e('Unexpected error in TaxCodeService: $e', error: e, stackTrace: s);
      throw TaxCodeApiServerException('calculation-failed');
    }
  }
}
