import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/tax_code_response.dart';

void main() {
  /// Tests for the TaxCodeResponse model
  group('TaxCodeResponse Models', () {
    // Arrange: Create a fake JSON response to test the models
    final fakeJson = {
      'status': true,
      'message': 'Codice Fiscale Calcolato',
      'data': {
        'cf': 'RSSMRA80A01H501A',
        'all_cf': ['RSSMRA80A01H501A', 'RSSMRA80A01H501O'],
      },
    };

    final expectedData = const Data(
      fiscalCode: 'RSSMRA80A01H501A',
      allFiscalCodes: ['RSSMRA80A01H501A', 'RSSMRA80A01H501O'],
    );

    final expectedResponse = TaxCodeResponse(
      status: true,
      message: 'Codice Fiscale Calcolato',
      data: expectedData,
    );

    group('Equality', () {
      test('Data instances with same values should be equal', () {
        const data1 = Data(fiscalCode: 'ABC', allFiscalCodes: ['123']);
        const data2 = Data(fiscalCode: 'ABC', allFiscalCodes: ['123']);
        expect(data1, equals(data2));
      });

      test('TaxCodeResponse instances with same values should be equal', () {
        const response1 = TaxCodeResponse(
          status: true,
          message: 'OK',
          data: Data(fiscalCode: 'ABC', allFiscalCodes: ['123']),
        );
        const response2 = TaxCodeResponse(
          status: true,
          message: 'OK',
          data: Data(fiscalCode: 'ABC', allFiscalCodes: ['123']),
        );
        expect(response1, equals(response2));
      });
    });

    /// Tests for the Data model
    group('Data Model', () {
      test('fromJson should create a valid model from map', () {
        // Act
        final result = Data.fromJson(fakeJson['data'] as Map<String, dynamic>);
        // Assert
        expect(result, equals(expectedData));
      });

      test('toJson should return a valid map', () {
        // Act
        final result = expectedData.toJson();
        // Assert
        expect(result, equals(fakeJson['data']));
      });
    });

    /// Tests for the TaxCodeResponse model
    group('TaxCodeResponse Model', () {
      test('fromJson should create a valid model from map', () {
        // Act
        final result = TaxCodeResponse.fromJson(fakeJson);
        // Assert
        expect(result, equals(expectedResponse));
      });

      test('toJson should return a valid map', () {
        // Act
        final result = expectedResponse.toJson();
        // Assert
        expect(result, equals(fakeJson));
      });
    });
  });
}
