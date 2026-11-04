import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/contact_resolution_service.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';

/// Manages the state and business logic for the HomePage.
interface class HomePageController with ChangeNotifier {
  final ContactRepository _contactRepository;
  final SharingService _sharingService;
  final BirthplaceService _birthplaceService;
  final ContactResolutionService _contactResolutionService;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  String _searchText = '';
  bool _isLoading = true;

  List<Contact> get contactsToShow => _filteredContacts;
  bool get isLoading => _isLoading;
  String get searchText => _searchText;
  bool get isReorderable => _searchText.isEmpty;
  bool get hasContacts => _allContacts.isNotEmpty;

  HomePageController({
    required ContactRepository contactRepository,
    required SharingService sharingService,
    required BirthplaceService birthplaceService,
    ContactResolutionService contactResolutionService =
        const ContactResolutionService(),
  }) : _contactRepository = contactRepository,
       _sharingService = sharingService,
       _birthplaceService = birthplaceService,
       _contactResolutionService = contactResolutionService {
    _initialize();
  }

  /// Filters the contact list based on the provided search text.
  void filterContacts(String text) {
    _searchText = text.toLowerCase();
    _applyFilter();
  }

  /// Reorders the contacts and persists the new order.
  void reorderContacts(int oldIndex, int newIndex) {
    final reorderedContacts = List<Contact>.from(_allContacts);
    final contact = reorderedContacts.removeAt(oldIndex);
    reorderedContacts.insert(newIndex, contact);
    _allContacts = reorderedContacts;
    _applyFilter();
    unawaited(_contactRepository.updateContacts(reorderedContacts));
  }

  /// Saves a new or updated contact.
  void saveContact(Contact contact) {
    unawaited(_contactRepository.addOrUpdateContact(contact));
  }

  /// Deletes a contact.
  void deleteContact(Contact contact) {
    unawaited(_contactRepository.removeContact(contact));
  }

  /// Shares the contact's tax code via the SharingService.
  void shareContact(Contact contact) {
    unawaited(_sharingService.share(text: contact.taxCode));
  }

  /// Resolves and displays the barcode bottom sheet for a given deep link URI.
  ///
  /// Supports:
  /// - `taxcode://barcode` or `taxcode://barcode/me` (primary contact via 3-level strategy)
  /// - `taxcode://barcode/{contactId}` or `taxcode://barcode?id={contactId}`
  /// - `taxcode://barcode?query={nameOrTaxCode}`
  ///
  /// Returns the resolved [Contact] if found, or `null` otherwise.
  Future<Contact?> handleBarcodeDeepLink(
    BuildContext context,
    Uri uri, {
    String? userDisplayName,
    Future<void> Function(BuildContext, {required Contact contact})?
    showBarcodeSheet,
  }) async {
    if (uri.scheme != 'taxcode' && uri.scheme != 'app') return null;

    String? id = uri.queryParameters['id'];
    String? query = uri.queryParameters['query'];

    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      final first = segments.first;
      if (first == 'me' || first == 'io') {
        query = 'me';
      } else if (id == null && query == null) {
        id = first;
      }
    }

    final contact = _contactResolutionService.resolveContact(
      _allContacts,
      id: id,
      query: query,
      userDisplayName: userDisplayName,
    );

    if (contact != null) {
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        final shower = showBarcodeSheet ?? BarcodeBottomSheet.show;
        await shower(context, contact: contact);
      }
      return contact;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.barcodeDeepLinkNotFound),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    _contactRepository.removeListener(_onContactsChanged);
    super.dispose();
  }

  void _applyFilter() {
    if (_searchText.isEmpty) {
      _filteredContacts = _allContacts;
    } else {
      _filteredContacts = _allContacts
          .where(
            (c) =>
                c.taxCode.toLowerCase().contains(_searchText) ||
                c.firstName.toLowerCase().contains(_searchText) ||
                c.lastName.toLowerCase().contains(_searchText) ||
                c.birthPlace.name.toLowerCase().contains(_searchText),
          )
          .toList();
    }
    notifyListeners();
  }

  void _initialize() {
    _contactRepository.addListener(_onContactsChanged);
    _onContactsChanged();
    // Start birthplace sync in background as soon as app opens
    unawaited(_birthplaceService.loadBirthplaces());
  }

  /// Called whenever the ContactRepository notifies of a change.
  void _onContactsChanged() {
    _isLoading = _contactRepository.isLoading;
    _allContacts = _contactRepository.contacts;
    _applyFilter();
  }
}
