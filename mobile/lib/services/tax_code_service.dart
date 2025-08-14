import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
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
  final http.Client _client;
  final Logger _logger;
  final String _accessToken;

  TaxCodeService({
    required http.Client client,
    required Logger logger,
    required String accessToken,
  })  : _client = client,
        _logger = logger,
        _accessToken = accessToken;

  @override
  Future<TaxCodeResponse> fetchTaxCode({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthPlaceName,
    required String birthPlaceState,
    required DateTime birthDate,
  }) async {
    final baseUri = 'http://api.miocodicefiscale.com/calculate?';
    final params = 'lname=${lastName.trim()}&fname=${firstName.trim()}&gender=$gender'
        '&city=$birthPlaceName&state=$birthPlaceState'
        '&day=${birthDate.day}&month=${birthDate.month}&year=${birthDate.year}'
        '&access_token=$_accessToken';
    
    final uri = Uri.parse('$baseUri$params');

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TaxCodeResponse.fromJson(jsonDecode(response.body));
      } else {
        _logger.w('TaxCode API returned a server error: ${response.statusCode}');
        throw TaxCodeApiServerException(response.statusCode);
      }
    } on SocketException catch (e, s) {
      _logger.w('Network error during tax code fetch.', error: e, stackTrace: s);
      throw TaxCodeApiNetworkException();
    } on TimeoutException catch (e, s) {
      _logger.w('Timeout during tax code fetch.', error: e, stackTrace: s);
      throw TaxCodeApiNetworkException();
    } catch (e, s) {
      _logger.e('Unexpected error in TaxCodeService.', error: e, stackTrace: s);
      rethrow;
    }
  }
}