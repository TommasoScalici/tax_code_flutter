import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:tax_code_flutter/controllers/form_page_controller.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/screens/form_page.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() {
    setupTests();
  });

  late MockBirthplaceService mockBirthplaceService;
  late MockContactRepository mockContactRepository;
  late MockTaxCodeService mockTaxCodeService;

  final mockBirthplace = const Birthplace(name: 'ROMA', state: 'RM');

  final mockContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1990, 1, 1),
    birthPlace: mockBirthplace,
    taxCode: '',
    listIndex: 0,
  );

  final mockResponse = const TaxCodeResponse(
    status: true,
    message: 'Success',
    data: Data(
      fiscalCode: 'RSSMRA90A01H501A',
      allFiscalCodes: ['RSSMRA90A01H501A'],
    ),
  );

  setUp(() {
    mockBirthplaceService = MockBirthplaceService();
    mockContactRepository = MockContactRepository();
    mockTaxCodeService = MockTaxCodeService();

    when(
      () => mockBirthplaceService.loadBirthplaces(),
    ).thenAnswer((_) async => [mockBirthplace]);
    when(() => mockContactRepository.contacts).thenReturn([]);
  });

  group('FormPage Widget Tests - Initial State', () {
    testWidgets('shows loading indicator while initializing', (tester) async {
      // Arrange
      final completer = Completer<List<Birthplace>>();
      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) => completer.future);

      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('First Name'), findsNothing);

      // Cleanup
      addTearDown(() => completer.complete([]));
    });

    testWidgets('renders form fields when loaded', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveTextField &&
              widget.formControlName == 'firstName',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveTextField &&
              widget.formControlName == 'lastName',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveDropdownField &&
              widget.formControlName == 'gender',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveDateTimePicker &&
              widget.formControlName == 'birthDate',
        ),
        findsOneWidget,
      );

      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('Confirm button is disabled when form is loaded and empty', (
      tester,
    ) async {
      // Arrange
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      // Act
      final buttonFinder = find.ancestor(
        of: find.text('Confirm'), // Trova prima il testo "Confirm"
        matching: find.byType(FilledButton),
      );

      final confirmButton = tester.widget<FilledButton>(buttonFinder);

      // Assert
      expect(confirmButton.onPressed, isNull);
    });
  });

  group('FormPage Widget Tests - UI State', () {
    testWidgets('adds bottom padding when birthplace field is focused', (
      tester,
    ) async {
      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      Padding findScaffoldPadding() {
        return tester.widget<Padding>(
          find.descendant(
            of: find.byType(Scaffold),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Padding && widget.child is SingleChildScrollView,
            ),
          ),
        );
      }

      // Assert
      var paddingWidget = findScaffoldPadding();
      expect(paddingWidget.padding.resolve(TextDirection.ltr).bottom, 0);

      // Act
      final birthplaceField = find.byWidgetPredicate(
        (widget) =>
            widget is ReactiveRawAutocomplete &&
            widget.formControlName == 'birthPlace',
      );
      await tester.tap(birthplaceField);
      await tester.pump();

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);

      await tester.pump();

      // Assert
      paddingWidget = findScaffoldPadding();
      expect(
        paddingWidget.padding.resolve(TextDirection.ltr).bottom,
        greaterThan(0),
      );

      addTearDown(
        () => tester.view.viewInsets = const FakeViewPadding(
          bottom: 0,
          top: 0,
          left: 0,
          right: 0,
        ),
      );
    });

    testWidgets('clears birthplace field when clear icon is tapped', (
      tester,
    ) async {
      // Arrange
      final mockBirthplace = const Birthplace(name: 'ROMA', state: 'RM');
      final mockContact = Contact(
        id: '1',
        firstName: 'Mario',
        lastName: 'Rossi',
        gender: 'M',
        birthDate: DateTime(1990, 1, 1),
        birthPlace: mockBirthplace,
        taxCode: '',
        listIndex: 0,
      );

      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) async => [mockBirthplace]);

      // Act
      await pumpApp(
        tester,
        FormPage(contact: mockContact),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      // Assert
      final birthplaceFieldFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ReactiveRawAutocomplete &&
            widget.formControlName == 'birthPlace',
      );
      var birthplaceTextField = tester.widget<TextField>(
        find.descendant(
          of: birthplaceFieldFinder,
          matching: find.byType(TextField),
        ),
      );

      expect(birthplaceTextField.controller!.text, 'ROMA (RM)');

      // Act
      final clearIconFinder = find.descendant(
        of: birthplaceFieldFinder,
        matching: find.byIcon(Icons.clear),
      );
      await tester.tap(clearIconFinder);
      await tester.pump();

      // Assert
      birthplaceTextField = tester.widget<TextField>(
        find.descendant(
          of: birthplaceFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(birthplaceTextField.controller!.text, isEmpty);
    });
  });

  group('FormPage Widget Tests - Scan Card', () {
    final mockScannedData = ScannedData(
      firstName: 'Laura',
      lastName: 'Neri',
      gender: 'F',
      birthDate: DateTime(1985, 10, 20),
      birthPlace: const Birthplace(name: 'MILANO', state: 'MI'),
    );

    final mockBirthplace = const Birthplace(name: 'MILANO', state: 'MI');

    testWidgets('populates form when CameraPage returns scanned data', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) async => [mockBirthplace]);

      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Symbols.id_card));

      await tester.binding.setSurfaceSize(const Size(800, 600));
      tester.binding.scheduleFrameCallback((_) {
        Navigator.pop(tester.element(find.byType(FormPage)), mockScannedData);
      });
      await tester.pumpAndSettle();

      // Assert
      final firstNameFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ReactiveTextField &&
            widget.formControlName == 'firstName',
      );
      final firstNameTextField = tester.widget<TextField>(
        find.descendant(of: firstNameFinder, matching: find.byType(TextField)),
      );
      expect(firstNameTextField.controller!.text, 'Laura');

      final lastNameFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ReactiveTextField && widget.formControlName == 'lastName',
      );
      final lastNameTextField = tester.widget<TextField>(
        find.descendant(of: lastNameFinder, matching: find.byType(TextField)),
      );
      expect(lastNameTextField.controller!.text, 'Neri');

      final element = tester.element(firstNameFinder);
      final controller = element.read<FormPageController>();
      expect(controller.form.control('gender').value, 'F');
      expect(
        controller.form.control('birthDate').value,
        DateTime(1985, 10, 20),
      );

      expect(controller.form.control('birthPlace').value, mockBirthplace);
    });
  });

  group('FormPage Widget Tests - Validation', () {
    testWidgets('shows an error when "firstName" is touched and left empty', (
      tester,
    ) async {
      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveTextField &&
              widget.formControlName == 'firstName',
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveTextField &&
              widget.formControlName == 'lastName',
        ),
      );
      await tester.pump();

      // Assert
      final inputDecorator = tester.widget<InputDecorator>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is ReactiveTextField &&
                widget.formControlName == 'firstName',
          ),
          matching: find.byType(InputDecorator),
        ),
      );

      expect(inputDecorator.decoration.errorText, isNotNull);
    });

    testWidgets('shows an error for invalid characters in "firstName"', (
      tester,
    ) async {
      // Act
      await pumpApp(
        tester,
        const FormPage(),
        mockBirthplaceService: mockBirthplaceService,
        mockContactRepository: mockContactRepository,
      );

      await tester.pumpAndSettle();

      final firstNameField = find.byWidgetPredicate(
        (widget) =>
            widget is ReactiveTextField &&
            widget.formControlName == 'firstName',
      );
      await tester.tap(firstNameField);
      await tester.pump();

      await tester.enterText(firstNameField, 'Mario123');
      await tester.pump();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReactiveTextField &&
              widget.formControlName == 'lastName',
        ),
      );
      await tester.pump();

      // Assert
      final inputDecorator = tester.widget<InputDecorator>(
        find.descendant(
          of: firstNameField,
          matching: find.byType(InputDecorator),
        ),
      );

      expect(inputDecorator.decoration.errorText, isNotNull);

      final confirmButtonFinder = find.ancestor(
        of: find.text('Confirm'),
        matching: find.byType(FilledButton),
      );
      final confirmButton = tester.widget<FilledButton>(confirmButtonFinder);
      expect(confirmButton.onPressed, isNull);
    });
  });

  group('FormPage Widget Tests - Submission', () {
    testWidgets('submits successfully when form is pre-filled and valid', (
      tester,
    ) async {
      // Arrange

      when(
        () => mockTaxCodeService.fetchTaxCode(
          firstName: 'Mario',
          lastName: 'Rossi',
          gender: 'M',
          birthDate: DateTime(1990, 1, 1),
          birthPlaceName: 'ROMA',
          birthPlaceState: 'RM',
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await pumpApp(
        tester,
        FormPage(contact: mockContact),
        mockBirthplaceService: mockBirthplaceService,
        mockTaxCodeService: mockTaxCodeService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      // Assert
      final confirmButtonFinder = find.ancestor(
        of: find.text('Confirm'),
        matching: find.byType(FilledButton),
      );
      final confirmButton = tester.widget<FilledButton>(confirmButtonFinder);
      expect(confirmButton.onPressed, isNotNull);

      // Act
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockTaxCodeService.fetchTaxCode(
          firstName: 'Mario',
          lastName: 'Rossi',
          gender: 'M',
          birthDate: DateTime(1990, 1, 1),
          birthPlaceName: 'ROMA',
          birthPlaceState: 'RM',
        ),
      ).called(1);
    });

    testWidgets('shows error dialog when submit fails with network error', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) async => [mockBirthplace]);
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
      await pumpApp(
        tester,
        FormPage(contact: mockContact),
        mockBirthplaceService: mockBirthplaceService,
        mockTaxCodeService: mockTaxCodeService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      final confirmButtonFinder = find.ancestor(
        of: find.text('Confirm'),
        matching: find.byType(FilledButton),
      );
      await tester.tap(confirmButtonFinder);

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Connection Error. Please check your internet connection.'),
        findsOneWidget,
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'shows generic error dialog when submit fails with unknown error',
      (tester) async {
        // Arrange
        when(
          () => mockBirthplaceService.loadBirthplaces(),
        ).thenAnswer((_) async => [mockBirthplace]);

        when(
          () => mockTaxCodeService.fetchTaxCode(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            gender: any(named: 'gender'),
            birthDate: any(named: 'birthDate'),
            birthPlaceName: any(named: 'birthPlaceName'),
            birthPlaceState: any(named: 'birthPlaceState'),
          ),
        ).thenThrow(Exception('A generic, unknown error'));

        // Act
        await pumpApp(
          tester,
          FormPage(contact: mockContact),
          mockBirthplaceService: mockBirthplaceService,
          mockTaxCodeService: mockTaxCodeService,
          mockContactRepository: mockContactRepository,
        );
        await tester.pumpAndSettle();

        final confirmButtonFinder = find.ancestor(
          of: find.text('Confirm'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(confirmButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('An unexpected error occurred.'), findsOneWidget);
      },
    );

    testWidgets('shows generic error dialog when API returns status false', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBirthplaceService.loadBirthplaces(),
      ).thenAnswer((_) async => [mockBirthplace]);

      final mockFailedResponse = const TaxCodeResponse(
        status: false,
        message: 'Invalid data provided',
        data: Data(fiscalCode: '', allFiscalCodes: []),
      );
      when(
        () => mockTaxCodeService.fetchTaxCode(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          birthDate: any(named: 'birthDate'),
          birthPlaceName: any(named: 'birthPlaceName'),
          birthPlaceState: any(named: 'birthPlaceState'),
        ),
      ).thenAnswer((_) async => mockFailedResponse);

      // Act
      await pumpApp(
        tester,
        FormPage(contact: mockContact),
        mockBirthplaceService: mockBirthplaceService,
        mockTaxCodeService: mockTaxCodeService,
        mockContactRepository: mockContactRepository,
      );
      await tester.pumpAndSettle();

      final confirmButtonFinder = find.ancestor(
        of: find.text('Confirm'),
        matching: find.byType(FilledButton),
      );
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('An unexpected error occurred.'), findsOneWidget);
    });
  });
}
