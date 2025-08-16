import 'package:flutter/material.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

/// Manages the state and business logic for the HomePage.
class HomePageController with ChangeNotifier {
  final ContactRepository _contactRepository;
  final SharingServiceAbstract _sharingService;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  String _searchText = '';
  bool _isLoading = true;

  List<Contact> get contactsToShow => _filteredContacts;
  bool get isLoading => _isLoading;
  String get searchText => _searchText;
  bool get isReorderable => _searchText.isEmpty;

  HomePageController({
    required ContactRepository contactRepository,
    required SharingServiceAbstract sharingService,
  })
      : _contactRepository = contactRepository,
        _sharingService = sharingService {
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
    _contactRepository.updateContacts(reorderedContacts);
  }

  /// Saves a new or updated contact.
  void saveContact(Contact contact) {
    _contactRepository.addOrUpdateContact(contact);
  }

  /// Deletes a contact.
  void deleteContact(Contact contact) {
    _contactRepository.removeContact(contact);
  }

  /// Shares the contact's tax code via the SharingService.
  void shareContact(Contact contact) {
    _sharingService.share(text: contact.taxCode);
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
          .where((c) =>
              c.taxCode.toLowerCase().contains(_searchText) ||
              c.firstName.toLowerCase().contains(_searchText) ||
              c.lastName.toLowerCase().contains(_searchText) ||
              c.birthPlace.name.toLowerCase().contains(_searchText))
          .toList();
    }
    notifyListeners();
  }

  void _initialize() {
    _contactRepository.addListener(_onContactsChanged);
    _onContactsChanged();
  }

  /// Called whenever the ContactRepository notifies of a change.
  void _onContactsChanged() {
    _isLoading = _contactRepository.isLoading;
    _allContacts = _contactRepository.contacts;
    _applyFilter();
  }
}