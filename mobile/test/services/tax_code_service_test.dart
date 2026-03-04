import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

// --- Mocks ---
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult {}

class MockLogger extends Mock implements Logger {}

void main() {
  late TaxCodeService taxCodeService;
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockHttpsCallable;
  late MockHttpsCallableResult mockResult;
  late MockLogger mockLogger;

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockHttpsCallable = MockHttpsCallable();
    mockResult = MockHttpsCallableResult();
    mockLogger = MockLogger();

    taxCodeService = TaxCodeService(
      functions: mockFunctions,
      logger: mockLogger,
    );
  });

  // Dummy data for the service call
  const tFirstName = 'Mario';
  const tLastName = 'Rossi';
  const tGender = 'M';
  const tBirthPlaceName = 'Roma';
  const tBirthPlaceState = 'RM';
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
    final Map<String, dynamic> fakeResponseData = {
      'status': true,
      'message': 'OK',
      'data': {
        'cf': 'RSSMRA80A01H501U',
        'all_cf': ['RSSMRA80A01H501U'],
      },
    };

    test(
      'should return TaxCodeResponse when the Cloud Function succeeds',
      () async {
        // Arrange
        when(
          () => mockFunctions.httpsCallable(any()),
        ).thenReturn(mockHttpsCallable);
        when(
          () => mockHttpsCallable.call(any()),
        ).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn(fakeResponseData);

        // Act
        final result = await callFetchTaxCode();

        // Assert
        expect(result.data.fiscalCode, 'RSSMRA80A01H501U');
        verify(() => mockFunctions.httpsCallable('calculateTaxCode')).called(1);
      },
    );

    test(
      'should throw a TaxCodeApiServerException when the Cloud Function throws',
      () async {
        // Arrange
        when(
          () => mockFunctions.httpsCallable(any()),
        ).thenReturn(mockHttpsCallable);
        when(() => mockHttpsCallable.call(any())).thenThrow(
          FirebaseFunctionsException(message: 'Error', code: 'internal'),
        );

        // Act & Assert
        try {
          await callFetchTaxCode();
          fail('should have thrown a TaxCodeApiServerException');
        } catch (e) {
          expect(e, isA<TaxCodeApiServerException>());
          verify(
            () => mockLogger.w(
              any(),
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        }
      },
    );
  });
}
