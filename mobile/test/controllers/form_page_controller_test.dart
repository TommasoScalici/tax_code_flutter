import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/controllers/form_page_controller.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

// Mocks for dependencies that have logic
class MockTaxCodeService extends Mock implements TaxCodeServiceAbstract {}

class MockBirthplaceService extends Mock implements BirthplaceServiceAbstract {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockLogger extends Mock implements Logger {}

// Fakes for simple data models used in `registerFallbackValue`
class FakeContact extends Fake implements Contact {}

class FakeBirthplace extends Fake implements Birthplace {}

class FakeScannedData extends Fake implements ScannedData {}

void main() {
  group('OnlyLettersValidator', () {
    const validator = OnlyLettersValidator();

    test(
      'should return null for valid input (letters, spaces, apostrophes)',
      () {
        final control = FormControl<String>(value: "D'Angelo");
        expect(validator.validate(control), isNull);
      },
    );

    test('should return error map for invalid input (numbers)', () {
      final control = FormControl<String>(value: 'Mario123');
      expect(validator.validate(control), {'invalidCharacters': true});
    });

    test('should return null for empty or null value', () {
      final control = FormControl<String>();
      expect(validator.validate(control), isNull);
    });
  });

  // Test group for the controller
  group('FormPageController', () {
    late FormPageController formPageController;
    late MockTaxCodeService mockTaxCodeService;
    late MockBirthplaceService mockBirthplaceService;
    late MockContactRepository mockContactRepository;
    late MockLogger mockLogger;

    final sampleBirthplace = const Birthplace(name: 'Palermo', state: 'PA');
    final sampleContact = Contact(
      id: 'test-id',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01G273M',
      birthPlace: sampleBirthplace,
      birthDate: DateTime(1980, 1, 1),
      listIndex: 1,
    );

    // This setup runs before each test, ensuring a clean state
    setUp(() {
      mockTaxCodeService = MockTaxCodeService();
      mockBirthplaceService = MockBirthplaceService();
      mockContactRepository = MockContactRepository();
      mockLogger = MockLogger();

      // Register fallbacks for any custom types used in mocked method calls
      registerFallbackValue(FakeContact());
      registerFallbackValue(FakeBirthplace());

      // Default stubbing for methods called during initialization or submission
      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) async => [sampleBirthplace]);
      when(() => mockContactRepository.contacts).thenReturn([]);
      when(
        () => mockLogger.e(any(), error: any(named: 'error')),
      ).thenAnswer((_) {});
    });

    // Helper function to create the controller, as its initialization is async
    Future<void> createController({Contact? initialContact}) async {
      formPageController = FormPageController(
        taxCodeService: mockTaxCodeService,
        birthplaceService: mockBirthplaceService,
        contactRepository: mockContactRepository,
        logger: mockLogger,
        initialContact: initialContact,
      );
      // Wait for async operations in the controller's `_initialize` to complete
      await Future.delayed(Duration.zero);
    }

    test('initialization loads birthplaces and builds the form', () async {
      // Act
      await createController();

      // Assert
      verify(() => mockBirthplaceService.loadBirthplaces()).called(1);
      expect(formPageController.birthplaces, isNotEmpty);
      expect(formPageController.form, isA<FormGroup>());
      expect(formPageController.isLoading, isFalse);
    });

    test(
      'initializes form with data when initialContact is provided',
      () async {
        // Act
        await createController(initialContact: sampleContact);

        // Assert
        expect(
          formPageController.form.control('firstName').value,
          sampleContact.firstName,
        );
        expect(
          formPageController.form.control('lastName').value,
          sampleContact.lastName,
        );
        expect(
          formPageController.form.control('birthPlace').value,
          sampleContact.birthPlace,
        );
      },
    );

    test('populateFormFromScannedData patches form values correctly', () async {
      // Arrange
      await createController();
      final scannedData = ScannedData(
        firstName: 'Luigi',
        lastName: 'Verdi',
        gender: 'M',
        birthDate: DateTime(1990, 5, 5),
        birthPlace: sampleBirthplace,
      );

      // Act
      formPageController.populateFormFromScannedData(scannedData);

      // Assert
      expect(formPageController.form.control('firstName').value, 'Luigi');
      expect(formPageController.form.control('lastName').value, 'Verdi');
    });

    group('submitForm', () {
      // Use real model instances for the successful response
      final successfulData = const Data(
        fiscalCode: 'NEWTAXCODE123',
        allFiscalCodes: [],
      );
      final successfulResponse = TaxCodeResponse(
        status: true,
        message: 'OK',
        data: successfulData,
      );

      setUp(() {
        // Stub the service to return the successful response by default for all tests in this group
        when(
          () => mockTaxCodeService.fetchTaxCode(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            gender: any(named: 'gender'),
            birthDate: any(named: 'birthDate'),
            birthPlaceName: any(named: 'birthPlaceName'),
            birthPlaceState: any(named: 'birthPlaceState'),
          ),
        ).thenAnswer((_) async => successfulResponse);
      });

      test(
        'returns null and does not call service when form is invalid',
        () async {
          // Arrange
          await createController(); // Form is initially empty and thus invalid

          // Act
          final result = await formPageController.submitForm();

          // Assert
          expect(result, isNull);
          verifyNever(
            () => mockTaxCodeService.fetchTaxCode(
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              gender: any(named: 'gender'),
              birthDate: any(named: 'birthDate'),
              birthPlaceName: any(named: 'birthPlaceName'),
              birthPlaceState: any(named: 'birthPlaceState'),
            ),
          );
        },
      );

      test('returns a new Contact on successful submission', () async {
        // Arrange
        await createController();
        formPageController.form.patchValue({
          'firstName': 'Guido',
          'lastName': 'Bianchi',
          'gender': 'M',
          'birthDate': DateTime(1975, 3, 10),
          'birthPlace': sampleBirthplace,
        });

        // Act
        final result = await formPageController.submitForm();

        // Assert
        expect(result, isA<Contact>());
        expect(result?.firstName, 'Guido');
        expect(result?.taxCode, 'NEWTAXCODE123');
        expect(formPageController.errorMessage, isNull);
        expect(formPageController.isLoading, isFalse);
      });

      test(
        'sets network error message on TaxCodeApiNetworkException',
        () async {
          // Arrange
          await createController();
          formPageController.form.patchValue({
            'firstName': 'Guido',
            'lastName': 'Bianchi',
            'gender': 'M',
            'birthDate': DateTime(1975, 3, 10),
            'birthPlace': sampleBirthplace,
          });
          when(
            () => mockTaxCodeService.fetchTaxCode(
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              gender: any(named: 'gender'),
              birthDate: any(named: 'birthDate'),
              birthPlaceName: any(named: 'birthPlaceName'),
              birthPlaceState: any(named: 'birthPlaceState'),
            ),
          ).thenThrow(TaxCodeApiNetworkException());

          // Act
          final result = await formPageController.submitForm();

          // Assert
          expect(result, isNull);
          expect(formPageController.errorMessage, contains('Connection Error'));
        },
      );

      test('sets generic error message on TaxCodeApiServerException', () async {
        // Arrange
        await createController();
        formPageController.form.patchValue({
          'firstName': 'Guido',
          'lastName': 'Bianchi',
          'gender': 'M',
          'birthDate': DateTime(1975, 3, 10),
          'birthPlace': sampleBirthplace,
        });
        when(
          () => mockTaxCodeService.fetchTaxCode(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            gender: any(named: 'gender'),
            birthDate: any(named: 'birthDate'),
            birthPlaceName: any(named: 'birthPlaceName'),
            birthPlaceState: any(named: 'birthPlaceState'),
          ),
        ).thenThrow(TaxCodeApiServerException(500)); // Simulate a server error

        // Act
        final result = await formPageController.submitForm();

        // Assert
        expect(result, isNull);
        expect(formPageController.errorMessage, contains('unexpected error'));
        verify(() => mockLogger.e(any(), error: any(named: 'error'))).called(1);
      });
    });

    test('clearError resets error message and notifies listeners', () async {
      // Arrange
      await createController();
      var listenerCallCount = 0;
      formPageController.addListener(() => listenerCallCount++);

      // Manually set an error state to test clearing it
      formPageController.errorMessage = 'An old error';

      // Act
      formPageController.clearError();

      // Assert
      expect(formPageController.errorMessage, isNull);
      expect(listenerCallCount, greaterThan(0));
    });

    test('dispose cancels stream subscription', () async {
      // Arrange
      await createController();

      // Act
      formPageController.dispose();

      // Assert: The main purpose of this test is to ensure `dispose` can be called
      // without throwing an error, implicitly testing that the subscription is handled.
    });
  });
}
