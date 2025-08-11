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
