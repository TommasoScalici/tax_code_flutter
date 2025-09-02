import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';
import 'package:uuid/uuid.dart';

/// Validator that checks if a control's value contains only letters,
/// spaces, and apostrophes.
class OnlyLettersValidator implements Validator<dynamic> {
  const OnlyLettersValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    final hasInvalidCharacters = RegExp(
      r"[^a-zA-Z\s']",
    ).hasMatch(control.value.toString());

    return hasInvalidCharacters
        ? <String, dynamic>{'invalidCharacters': true}
        : null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FormPageController with ChangeNotifier {
  final TaxCodeServiceAbstract _taxCodeService;
  final BirthplaceServiceAbstract _birthplaceService;
  final ContactRepository _contactRepository;
  StreamSubscription? _formStatusSubscription;
  final Logger _logger;
  final Contact? _initialContact;
  late final FormGroup form;

  List<Birthplace> birthplaces = [];
  bool isLoading = false;
  String? errorMessage;

  FormPageController({
    required TaxCodeServiceAbstract taxCodeService,
    required BirthplaceServiceAbstract birthplaceService,
    required ContactRepository contactRepository,
    required Logger logger,
    Contact? initialContact,
  }) : _taxCodeService = taxCodeService,
       _birthplaceService = birthplaceService,
       _contactRepository = contactRepository,
       _logger = logger,
       _initialContact = initialContact {
    _initialize();
  }

  @override
  void dispose() {
    _formStatusSubscription?.cancel();
    super.dispose();
  }

  void _buildForm() {
    form = fb.group({
      'firstName': FormControl<String>(
        value: _initialContact?.firstName,
        validators: <Validator<dynamic>>[
          Validators.required,
          OnlyLettersValidator(),
        ],
      ),
      'lastName': FormControl<String>(
        value: _initialContact?.lastName,
        validators: [Validators.required, OnlyLettersValidator()],
      ),
      'gender': FormControl<String>(
        value: _initialContact?.gender,
        validators: [Validators.required],
      ),
      'birthDate': FormControl<DateTime>(
        value: _initialContact?.birthDate,
        validators: [Validators.required],
      ),
      'birthPlace': FormControl<Birthplace>(
        value: _initialContact?.birthPlace,
        validators: [Validators.required],
      ),
    });

    _listenToFormStatus();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    _buildForm();
    await _loadBirthplaces();
    _setLoading(false);
  }

  void _listenToFormStatus() {
    _formStatusSubscription = form.statusChanged.listen((status) {
      notifyListeners();
    });
  }

  Future<void> _loadBirthplaces() async {
    birthplaces = await _birthplaceService.loadBirthplaces();
  }

  void _setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  /// Populates the form fields using data from a document scan.
  void populateFormFromScannedData(ScannedData data) {
    form.patchValue({
      'firstName': data.firstName,
      'lastName': data.lastName,
      'gender': data.gender,
      'birthDate': data.birthDate,
      'birthPlace': data.birthPlace,
    });
  }

  Future<Contact?> submitForm() async {
    form.markAllAsTouched();
    if (form.invalid) {
      return null;
    }

    _setLoading(true);
    clearError();

    try {
      final formData = form.value;
      final firstName = (formData['firstName'] as String).trim();
      final lastName = (formData['lastName'] as String).trim();
      final birthPlace = formData['birthPlace'] as Birthplace;

      final response = await _taxCodeService.fetchTaxCode(
        firstName: firstName,
        lastName: lastName,
        gender: formData['gender'] as String,
        birthDate: formData['birthDate'] as DateTime,
        birthPlaceName: birthPlace.name,
        birthPlaceState: birthPlace.state,
      );

      if (response.status) {
        final newContact = Contact(
          id: _initialContact?.id ?? const Uuid().v4(),
          firstName: firstName,
          lastName: lastName,
          gender: formData['gender'] as String,
          taxCode: response.data.fiscalCode,
          birthPlace: birthPlace,
          birthDate: formData['birthDate'] as DateTime,
          listIndex:
              _initialContact?.listIndex ??
              _contactRepository.contacts.length + 1,
        );
        _setLoading(false);
        return newContact;
      } else {
        throw Exception('API returned status false.');
      }
    } on TaxCodeApiNetworkException {
      _setError('Connection Error. Please check your internet connection.');
      _setLoading(false);
      return null;
    } catch (e) {
      _logger.e('An error occurred during form submission', error: e);
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return null;
    }
  }
}
