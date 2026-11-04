import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_functions/flutter_app_functions.dart';
import 'package:logger/logger.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/contact_resolution_service.dart';
import 'package:shared/utils/phonetic_spelling_formatter.dart';
import 'package:tax_code_flutter/services/deep_link_service.dart';
import 'package:tax_code_flutter/services/gemini_integration_service.dart';

/// Abstraction for registering [AppFunctionDefinition] with the underlying runtime.
abstract interface class AppFunctionsClient {
  void register(AppFunctionDefinition definition);
}

/// Default production client delegating to [FlutterAppFunctions.instance] on Android.
final class FlutterAppFunctionsClient implements AppFunctionsClient {
  const FlutterAppFunctionsClient();

  @override
  void register(AppFunctionDefinition definition) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      FlutterAppFunctions.instance.register(definition);
    }
  }
}

/// Service that defines and registers on-device Android AppFunctions for Google Gemini.
///
/// Exposes 4 functions:
/// 1. `getMyTaxCode`: Voice/headless retrieval of primary user's tax code.
/// 2. `getContactTaxCode`: Voice/headless retrieval of a contact's tax code by name.
/// 3. `openMyTaxCodeBarcode`: UI launch opening the BarcodeBottomSheet for the primary user.
/// 4. `openContactTaxCodeBarcode`: UI launch opening the BarcodeBottomSheet for a specific contact.
class AppFunctionsService {
  final ContactRepository _contactRepository;
  final ContactResolutionService _contactResolutionService;
  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final GeminiIntegrationService _geminiIntegrationService;
  final AppFunctionsClient _client;
  final Logger? _logger;

  final Map<String, AppFunctionDefinition> _definitions = {};

  AppFunctionsService({
    required ContactRepository contactRepository,
    required ContactResolutionService contactResolutionService,
    required AuthService authService,
    required DeepLinkService deepLinkService,
    required GeminiIntegrationService geminiIntegrationService,
    AppFunctionsClient client = const FlutterAppFunctionsClient(),
    Logger? logger,
  }) : _contactRepository = contactRepository,
       _contactResolutionService = contactResolutionService,
       _authService = authService,
       _deepLinkService = deepLinkService,
       _geminiIntegrationService = geminiIntegrationService,
       _client = client,
       _logger = logger;

  /// Map of all registered [AppFunctionDefinition]s, keyed by their ID.
  Map<String, AppFunctionDefinition> get definitions =>
      Map.unmodifiable(_definitions);

  /// Initializes and registers all AppFunctions definitions with the client.
  void init() {
    _registerDefinition(
      AppFunctionDefinition(
        id: 'getMyTaxCode',
        description:
            'Returns the tax code of the primary user or device owner from TaxCode, '
            'with optional Italian telephone phonetic spelling for voice dictation.',
        parameters: [
          AppFunctionParameter.bool(
            'spellOut',
            required: false,
            description:
                'Whether to spell out the tax code phonetically using the Italian telephone alphabet.',
          ),
        ],
        returnType: AppFunctionReturnType.string,
        handler: _handleGetMyTaxCode,
      ),
    );

    _registerDefinition(
      AppFunctionDefinition(
        id: 'getContactTaxCode',
        description:
            'Finds the tax code of a specific saved contact by name in TaxCode, '
            'with optional Italian telephone phonetic spelling for voice dictation.',
        parameters: [
          AppFunctionParameter.string(
            'name',
            description:
                'First name, last name, or full name of the contact to find in TaxCode.',
          ),
          AppFunctionParameter.bool(
            'spellOut',
            required: false,
            description:
                'Whether to spell out the tax code phonetically using the Italian telephone alphabet.',
          ),
        ],
        returnType: AppFunctionReturnType.string,
        handler: _handleGetContactTaxCode,
      ),
    );

    _registerDefinition(
      AppFunctionDefinition(
        id: 'openMyTaxCodeBarcode',
        description:
            'Opens the TaxCode app and displays the barcode and QR code bottom sheet '
            'for the primary user or device owner.',
        returnType: AppFunctionReturnType.string,
        handler: _handleOpenMyTaxCodeBarcode,
      ),
    );

    _registerDefinition(
      AppFunctionDefinition(
        id: 'openContactTaxCodeBarcode',
        description:
            'Opens the TaxCode app and displays the barcode and QR code bottom sheet '
            'for the specified contact by name.',
        parameters: [
          AppFunctionParameter.string(
            'name',
            description:
                'First name, last name, or full name of the contact whose barcode to open.',
          ),
        ],
        returnType: AppFunctionReturnType.string,
        handler: _handleOpenContactTaxCodeBarcode,
      ),
    );

    _logger?.d(
      'Registered ${_definitions.length} Gemini AppFunctions successfully',
    );
  }

  void _registerDefinition(AppFunctionDefinition definition) {
    _definitions[definition.id] = definition;
    _client.register(definition);
  }

  void _ensureGeminiEnabled() {
    if (!_geminiIntegrationService.isGeminiEnabled) {
      throw const AppFunctionDisabledException(
        'Google Gemini integration is disabled in TaxCode settings.',
      );
    }
  }

  Future<dynamic> _handleGetMyTaxCode(
    AppFunctionContext context,
    Map<String, dynamic> parameters,
  ) async {
    _ensureGeminiEnabled();

    final contacts = _contactRepository.contacts;
    final contact = _contactResolutionService.resolvePrimaryContact(
      contacts,
      userDisplayName: _authService.currentUser?.displayName,
    );

    if (contact == null) {
      throw const AppFunctionElementNotFoundException(
        'No primary tax code found. Set your contact as primary in TaxCode or specify a name.',
      );
    }

    final spellOut = parameters['spellOut'] == true;
    final phonetic = PhoneticSpellingFormatter.format(contact.taxCode);

    return jsonEncode({
      'fullName': '${contact.firstName} ${contact.lastName}'.trim(),
      'taxCode': contact.taxCode,
      'phoneticSpelling': phonetic,
      'spelledOut': spellOut,
    });
  }

  Future<dynamic> _handleGetContactTaxCode(
    AppFunctionContext context,
    Map<String, dynamic> parameters,
  ) async {
    _ensureGeminiEnabled();

    final name = (parameters['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const AppFunctionInvalidArgumentException(
        'Parameter "name" must not be empty.',
      );
    }

    final contacts = _contactRepository.contacts;
    final contact = _contactResolutionService.resolveContact(
      contacts,
      query: name,
    );

    if (contact == null) {
      throw AppFunctionElementNotFoundException(
        'No contact found matching "$name" in TaxCode.',
      );
    }

    final spellOut = parameters['spellOut'] == true;
    final phonetic = PhoneticSpellingFormatter.format(contact.taxCode);

    return jsonEncode({
      'fullName': '${contact.firstName} ${contact.lastName}'.trim(),
      'taxCode': contact.taxCode,
      'phoneticSpelling': phonetic,
      'spelledOut': spellOut,
    });
  }

  Future<dynamic> _handleOpenMyTaxCodeBarcode(
    AppFunctionContext context,
    Map<String, dynamic> parameters,
  ) async {
    _ensureGeminiEnabled();

    final contacts = _contactRepository.contacts;
    final contact = _contactResolutionService.resolvePrimaryContact(
      contacts,
      userDisplayName: _authService.currentUser?.displayName,
    );

    if (contact == null) {
      throw const AppFunctionElementNotFoundException(
        'No primary tax code found to display.',
      );
    }

    _deepLinkService.setPendingDeepLink(Uri.parse('taxcode://barcode/me'));

    return jsonEncode({
      'status': 'opened',
      'target': 'me',
      'fullName': '${contact.firstName} ${contact.lastName}'.trim(),
      'taxCode': contact.taxCode,
    });
  }

  Future<dynamic> _handleOpenContactTaxCodeBarcode(
    AppFunctionContext context,
    Map<String, dynamic> parameters,
  ) async {
    _ensureGeminiEnabled();

    final name = (parameters['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const AppFunctionInvalidArgumentException(
        'Parameter "name" must not be empty.',
      );
    }

    final contacts = _contactRepository.contacts;
    final contact = _contactResolutionService.resolveContact(
      contacts,
      query: name,
    );

    if (contact == null) {
      throw AppFunctionElementNotFoundException(
        'No contact found matching "$name" in TaxCode.',
      );
    }

    _deepLinkService.setPendingDeepLink(
      Uri.parse('taxcode://barcode/${contact.id}'),
    );

    return jsonEncode({
      'status': 'opened',
      'target': contact.id,
      'fullName': '${contact.firstName} ${contact.lastName}'.trim(),
      'taxCode': contact.taxCode,
    });
  }
}
