import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/tax_code_response.dart';

/// Exception for network errors during tax code fetching.
class TaxCodeApiNetworkException implements Exception {}

/// Exception for server errors during tax code fetching.
class TaxCodeApiServerException implements Exception {
  final int statusCode;
  TaxCodeApiServerException(this.statusCode);
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
/// This class is responsible for fetching tax codes from the TaxCode API.
class TaxCodeService implements TaxCodeServiceAbstract {
  final FirebaseFunctions _functions;
  final Logger _logger;

  TaxCodeService({required FirebaseFunctions functions, required Logger logger})
    : _functions = functions,
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
      final response = await _functions.httpsCallable('calculateTaxCode').call({
        'fname': firstName.trim(),
        'lname': lastName.trim(),
        'gender': gender,
        'city': birthPlaceName,
        'state': birthPlaceState,
        'day': birthDate.day.toString(),
        'month': birthDate.month.toString(),
        'year': birthDate.year.toString(),
      });

      return TaxCodeResponse.fromJson(Map<String, dynamic>.from(response.data));
    } on FirebaseFunctionsException catch (e, s) {
      _logger.w(
        'TaxCode Cloud Function error: ${e.code}',
        error: e,
        stackTrace: s,
      );
      throw TaxCodeApiServerException(500); // Map to internal server error
    } catch (e, s) {
      _logger.e('Unexpected error in TaxCodeService.', error: e, stackTrace: s);
      rethrow;
    }
  }
}
