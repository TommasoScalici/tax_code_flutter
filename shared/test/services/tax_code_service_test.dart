import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';

// --- Mocks ---
class MockBirthplaceService extends Mock implements BirthplaceServiceAbstract {}

class MockLogger extends Mock implements Logger {}

void main() {
  late TaxCodeService taxCodeService;
  late MockBirthplaceService mockBirthplaceService;
  late MockLogger mockLogger;

  setUp(() {
    mockBirthplaceService = MockBirthplaceService();
    mockLogger = MockLogger();

    taxCodeService = TaxCodeService(
      birthplaceService: mockBirthplaceService,
      logger: mockLogger,
    );
  });

  // Dummy data for the service call
  const tFirstName = 'Mario';
  const tLastName = 'Rossi';
  const tGender = 'M';
  const tBirthPlaceName = 'Roma';
  const tBirthPlaceState = 'RM';
  final tBirthDate = DateTime(1980, 1, 5); // Jan 5, 1980

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

  group('TaxCodeService Local Calculation', () {
    test(
      'should return TaxCodeResponse with correct locally generated code',
      () async {
        // Arrange
        when(() => mockBirthplaceService.loadBirthplaces()).thenAnswer(
          (_) async => [
            const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
            const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
          ],
        );

        // Act
        final result = await callFetchTaxCode();

        // Assert
        expect(result.status, true);
        expect(result.data.fiscalCode, 'RSSMRA80A05H501H');
        expect(result.data.allFiscalCodes, contains('RSSMRA80A05H501H'));
        verify(() => mockBirthplaceService.loadBirthplaces()).called(1);
      },
    );

    test(
      'should throw a TaxCodeApiServerException when birthplace is not found',
      () async {
        // Arrange
        when(() => mockBirthplaceService.loadBirthplaces()).thenAnswer(
          (_) async => [
            const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
          ],
        );

        // Act & Assert
        expect(callFetchTaxCode, throwsA(isA<TaxCodeApiServerException>()));
      },
    );
  });
}
