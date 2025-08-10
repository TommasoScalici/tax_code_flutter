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

    /// Tests for the Data model
    test('Data.fromJson should correctly parse the data object', () {
      final dataMap = fakeJson['data'] as Map<String, dynamic>;
      final dataModel = Data.fromJson(dataMap);

      expect(dataModel.cf, 'RSSMRA80A01H501A');
      expect(dataModel.all_cf, isA<List<String>>());
      expect(dataModel.all_cf.length, 2);
      expect(dataModel.all_cf.first, 'RSSMRA80A01H501A');
    });

    /// Tests for the TaxCodeResponse model
    test(
      'TaxCodeResponse.fromJson should correctly parse the full response',
      () {
        final responseModel = TaxCodeResponse.fromJson(fakeJson);

        expect(responseModel.status, isTrue);
        expect(responseModel.message, 'Codice Fiscale Calcolato');
        expect(responseModel.data, isA<Data>());
        expect(responseModel.data.cf, 'RSSMRA80A01H501A');
      },
    );
  });
}
