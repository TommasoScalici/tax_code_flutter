import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/utils/error_mapper.dart';
import 'package:tax_code_flutter/validators/only_letters_validator.dart';
import 'package:uuid/uuid.dart';

interface class FormPageController with ChangeNotifier {
  final TaxCodeServiceAbstract _taxCodeService;
  final BirthplaceServiceAbstract _birthplaceService;
  final ContactRepository _contactRepository;
  StreamSubscription<ControlStatus>? _formStatusSubscription;
  final Logger _logger;
  final Contact? _initialContact;
  late final FormGroup form;
  late final Future<void> initializationFuture;

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
    _buildForm();
    initializationFuture = initialize();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_formStatusSubscription?.cancel());
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
      final firstName = (formData['firstName']! as String).trim();
      final lastName = (formData['lastName']! as String).trim();
      final birthPlace = formData['birthPlace']! as Birthplace;

      final response = await _taxCodeService.fetchTaxCode(
        firstName: firstName,
        lastName: lastName,
        gender: formData['gender']! as String,
        birthDate: formData['birthDate']! as DateTime,
        birthPlaceName: birthPlace.name,
        birthPlaceState: birthPlace.state,
      );

      if (response.status) {
        final newContact = Contact(
          id: _initialContact?.id ?? const Uuid().v4(),
          firstName: firstName,
          lastName: lastName,
          gender: formData['gender']! as String,
          taxCode: response.data.fiscalCode,
          birthPlace: birthPlace,
          birthDate: formData['birthDate']! as DateTime,
          listIndex:
              _initialContact?.listIndex ??
              _contactRepository.contacts.length + 1,
        );
        _setLoading(false);
        return newContact;
      } else {
        throw Exception('API returned status false.');
      }
    } on Object catch (e) {
      _logger.e('Error during form submission', error: e);
      _setErrorKey(ErrorMapper.mapErrorToKey(e));
      _setLoading(false);
      return null;
    }
  }
}
