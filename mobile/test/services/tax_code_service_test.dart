import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

// --- Mocks ---
class MockHttpClient extends Mock implements http.Client {}

class MockLogger extends Mock implements Logger {}

void main() {
  late TaxCodeService taxCodeService;
  late MockHttpClient mockHttpClient;
  late MockLogger mockLogger;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockLogger = MockLogger();

    registerFallbackValue(Uri.parse('http://fake.url'));
    registerFallbackValue(StackTrace.current);
    registerFallbackValue(Object());

    taxCodeService = TaxCodeService(
      client: mockHttpClient,
      logger: mockLogger,
      accessToken: 'test_token',
    );
  });

  // Dummy data for the service call
  final tFirstName = 'Mario';
  final tLastName = 'Rossi';
  final tGender = 'M';
  final tBirthPlaceName = 'Roma';
  final tBirthPlaceState = 'RM';
  final tBirthDate = DateTime(1980, 1, 1);

  Future<TaxCodeResponse> callFetchTaxCode() {
    return taxCodeService.fetchTaxCode(
      firstName: tFirstName,
      lastName: tLastName,
      gender: tGender,
      birthPlaceName: tBirthPlaceName,
      birthPlaceState: tBirthPlaceState,
      birthDate: tBirthDate,
    );
  }

  group('TaxCodeService', () {
    final fakeJsonResponse = '''
      {
        "status": true,
        "message": "OK",
        "data": {
          "cf": "RSSMRA80A01H501U",
          "all_cf": ["RSSMRA80A01H501U"]
        }
      }
    ''';

    test(
      'should return TaxCodeResponse when the response code is 200 (success)',
      () async {
        // Arrange
        final expectedResponse = TaxCodeResponse.fromJson(
          jsonDecode(fakeJsonResponse),
        );

        when(() => mockHttpClient.get(any())).thenAnswer(
          (_) async => http.Response(
            fakeJsonResponse,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        );

        // Act
        final result = await callFetchTaxCode();

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.data.fiscalCode, 'RSSMRA80A01H501U');
      },
    );

    test(
      'should throw a TaxCodeApiServerException when the response code is not 200',
      () async {
        // Arrange
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act & Assert
        try {
          await callFetchTaxCode();
          fail('should have thrown a TaxCodeApiServerException');
        } catch (e) {
          expect(e, isA<TaxCodeApiServerException>());
          verify(() => mockLogger.w(any())).called(1);
        }
      },
    );

    test(
      'should throw a TaxCodeApiNetworkException on SocketException',
      () async {
        // Arrange
        when(
          () => mockHttpClient.get(any()),
        ).thenThrow(const SocketException('No internet'));

        // Act
        final call = callFetchTaxCode;

        // Assert
        expect(call, throwsA(isA<TaxCodeApiNetworkException>()));
      },
    );

    test('should call the client with the correct URI', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          fakeJsonResponse,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      // Act
      await callFetchTaxCode();

      // Assert
      final capturedUri =
          verify(() => mockHttpClient.get(captureAny())).captured.first as Uri;
      expect(capturedUri.host, 'api.miocodicefiscale.com');
      expect(capturedUri.queryParameters['fname'], tFirstName);
    });
  });
}
