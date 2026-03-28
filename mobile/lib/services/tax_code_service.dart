import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/tax_code_response.dart';

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
        'day': birthDate.day,
        'month': birthDate.month,
        'year': birthDate.year,
      });

      final sanitizedData = _sanitizeMap(response.data as Map?);
      return TaxCodeResponse.fromJson(sanitizedData);
    } on FirebaseFunctionsException catch (e, s) {
      _logger.w('TaxCode Cloud Function error: ${e.code}', error: e, stackTrace: s);
      if (e.code == 'unavailable') {
        throw TaxCodeApiNetworkException();
      }
      throw TaxCodeApiServerException(e.code);
    } catch (e, s) {
      _logger.e('Unexpected error in TaxCodeService: $e', error: e, stackTrace: s);
      throw TaxCodeApiNetworkException();
    }
  }

  Map<String, dynamic> _sanitizeMap(Map? map) {
    if (map == null) return {};

    return map.map((key, value) {
      final sanitizedKey = key.toString();
      dynamic sanitizedValue = value;

      if (value is Map) {
        sanitizedValue = _sanitizeMap(value);
      } else if (value is List) {
        sanitizedValue = value.map((e) {
          if (e is Map) return _sanitizeMap(e);
          return e;
        }).toList();
      }

      return MapEntry(sanitizedKey, sanitizedValue);
    });
  }
}
