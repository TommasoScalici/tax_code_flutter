import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';
import 'package:uuid/uuid.dart';

class FormPageController with ChangeNotifier {
  final TaxCodeServiceAbstract _taxCodeService;
  final BirthplaceServiceAbstract _birthplaceService;
  final ContactRepository _contactRepository;
  final Logger _logger;
  final Contact? _initialContact;

  final FormGroup form = FormGroup({
    'firstName': FormControl<String>(validators: [Validators.required]),
    'lastName': FormControl<String>(validators: [Validators.required]),
    'gender': FormControl<String>(validators: [Validators.required]),
    'birthDate': FormControl<DateTime>(validators: [Validators.required]),
    'birthPlace': FormControl<Birthplace>(validators: [Validators.required]),
  });

  List<Birthplace> birthplaces = [];
  bool isLoading = false;
  String? errorMessage;

  FormPageController({
    required TaxCodeServiceAbstract taxCodeService,
    required BirthplaceServiceAbstract birthplaceService,
    required ContactRepository contactRepository,
    required Logger logger,
    Contact? initialContact,
  })  : _taxCodeService = taxCodeService,
        _birthplaceService = birthplaceService,
        _contactRepository = contactRepository,
        _logger = logger,
        _initialContact = initialContact {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    await _loadBirthplaces();
    if (_initialContact != null) {
      populateFormFromContact(_initialContact);
    }
    _setLoading(false);
  }

  Future<void> _loadBirthplaces() async {
    birthplaces = await _birthplaceService.loadBirthplaces();
  }

  void populateFormFromContact(Contact contact) {
    form.control('firstName').value = contact.firstName;
    form.control('lastName').value = contact.lastName;
    form.control('gender').value = contact.gender;
    form.control('birthDate').value = contact.birthDate;
    form.control('birthPlace').value = contact.birthPlace;
    form.markAsDirty(); // Segna il form come modificato
  }

  Future<Contact?> submitForm() async {
    form.markAllAsTouched();
    if (form.invalid) {
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _taxCodeService.fetchTaxCode(
        firstName: form.control('firstName').value.trim(),
        lastName: form.control('lastName').value.trim(),
        gender: form.control('gender').value,
        birthDate: form.control('birthDate').value,
        birthPlaceName: (form.control('birthPlace').value as Birthplace).name,
        birthPlaceState: (form.control('birthPlace').value as Birthplace).state,
      );

      if (response.status) {
        final newContact = Contact(
          id: _initialContact?.id ?? const Uuid().v4(),
          firstName: form.control('firstName').value.trim(),
          lastName: form.control('lastName').value.trim(),
          gender: form.control('gender').value,
          taxCode: response.data.fiscalCode,
          birthPlace: form.control('birthPlace').value,
          birthDate: form.control('birthDate').value,
          listIndex: _initialContact?.listIndex ?? _contactRepository.contacts.length + 1,
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

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  void _setError(String message) {
    errorMessage = message;
    notifyListeners();
  }
}