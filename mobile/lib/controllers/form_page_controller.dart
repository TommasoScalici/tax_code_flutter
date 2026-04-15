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
class OnlyLettersValidator extends Validator<String> {
  const OnlyLettersValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<String> control) {
    if (control.value == null || control.value!.isEmpty) {
      return null;
    }

    final hasInvalidCharacters = RegExp(
      r"[^a-zA-Z\s']",
    ).hasMatch(control.value!);

    return hasInvalidCharacters
        ? <String, dynamic>{'invalidCharacters': true}
        : null;
  }
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
  bool _isDisposed = false;
  bool isLoading = false;
  bool isLoadingBirthplaces = false;
  String? errorKey;
  double? downloadProgress;
  String? downloadStep;

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
    initialize();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _formStatusSubscription?.cancel();
    super.dispose();
  }

  void _buildForm() {
    form = fb.group({
      'firstName': FormControl<String>(
        value: _initialContact?.firstName,
        validators: <Validator<dynamic>>[
          Validators.required,
          const OnlyLettersValidator(),
        ],
      ),
      'lastName': FormControl<String>(
        value: _initialContact?.lastName,
        validators: [Validators.required, const OnlyLettersValidator()],
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

  Future<void> initialize() async {
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
    isLoadingBirthplaces = true;
    _birthplaceService.downloadProgress.addListener(_onSyncProgressChanged);
    _birthplaceService.downloadStep.addListener(_onSyncProgressChanged);

    try {
      birthplaces = await _birthplaceService.loadBirthplaces();
    } finally {
      isLoadingBirthplaces = false;
      _birthplaceService.downloadProgress.removeListener(
        _onSyncProgressChanged,
      );
      _birthplaceService.downloadStep.removeListener(_onSyncProgressChanged);
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  void _onSyncProgressChanged() {
    if (_isDisposed) return;
    downloadProgress = _birthplaceService.downloadProgress.value;
    downloadStep = _birthplaceService.downloadStep.value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _setErrorKey(String key) {
    errorKey = key;
    notifyListeners();
  }

  void clearError() {
    if (errorKey != null) {
      errorKey = null;
      notifyListeners();
    }
  }

  void populateFormFromScannedData(ScannedData data) {
    final Map<String, dynamic> patch = {
      if (data.firstName != null) 'firstName': data.firstName,
      if (data.lastName != null) 'lastName': data.lastName,
      if (data.gender != null) 'gender': data.gender,
      if (data.birthDate != null) 'birthDate': data.birthDate,
      if (data.birthPlace != null) 'birthPlace': data.birthPlace,
    };
    form.patchValue(patch);
  }

  Future<Contact?> submitForm() async {
    form.markAllAsTouched();
    if (form.invalid) {
      return null;
    }

    _setLoading(true);
    clearError();

    try {
      if (birthplaces.isEmpty) {
        birthplaces = await _birthplaceService.loadBirthplaces();
      }

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
      _setErrorKey('networkError');
      _setLoading(false);
      return null;
    } on TaxCodeApiServerException catch (e) {
      _logger.e('Server error during form submission: ${e.code}');
      if (e.code == 'resource-exhausted') {
        _setErrorKey('rateLimitExceeded');
      } else if (e.code == 'unauthenticated' || e.code == 'permission-denied') {
        _setErrorKey('sessionExpired');
      } else if (e.code == 'deadline-exceeded') {
        _setErrorKey('deadlineExceeded');
      } else if (e.code == 'unavailable' || e.code == 'failed-precondition') {
        _setErrorKey('serviceUnavailable');
      } else {
        _setErrorKey('serviceUnavailable');
      }
      _setLoading(false);
      return null;
    } catch (e) {
      _logger.e('An error occurred during form submission', error: e);
      _setErrorKey('genericError');
      _setLoading(false);
      return null;
    }
  }
}
