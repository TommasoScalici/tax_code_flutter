import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';
import 'package:tax_code_flutter/screens/barcode_page.dart';
import 'package:tax_code_flutter/screens/form_page.dart';

/// Manages the state and business logic for the HomePage.
class HomePageController with ChangeNotifier {
  final ContactRepository _contactRepository;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  String _searchText = '';
  bool _isLoading = true;


  List<Contact> get contactsToShow => _filteredContacts;

  bool get isLoading => _isLoading;
  String get searchText => _searchText;
  bool get isReorderable => _searchText.isEmpty;

  HomePageController({required ContactRepository contactRepository})
      : _contactRepository = contactRepository {
    _initialize();
  }

  /// Filters the contact list based on the provided search text.
  void filterContacts(String text) {
    _searchText = text.toLowerCase();
    _applyFilter();
  }

  /// Reorders the contacts and persists the new order.
  void reorderContacts(int oldIndex, int newIndex) {
    // Important: Reorder the original list, not the filtered one.
    final reorderedContacts = List<Contact>.from(_allContacts);
    final contact = reorderedContacts.removeAt(oldIndex);
    reorderedContacts.insert(newIndex, contact);
    _contactRepository.updateContacts(reorderedContacts);
  }

  /// Opens the form to add a new contact and saves it upon return.
  Future<void> addNewContact(BuildContext context) async {
    final newContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const FormPage()),
    );
    if (newContact != null) {
      _contactRepository.addOrUpdateContact(newContact);
    }
  }

  /// Opens the form to edit an existing contact and saves it upon return.
  Future<void> editContact(BuildContext context, Contact contact) async {
    final editedContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => FormPage(contact: contact)),
    );
    if (editedContact != null) {
      _contactRepository.addOrUpdateContact(editedContact);
    }
  }

  /// Shows a confirmation dialog and deletes the contact if confirmed.
  Future<void> deleteContact(BuildContext context, Contact contact) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmation),
        content: Text(l10n.deleteMessage(contact.taxCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      _contactRepository.removeContact(contact);
    }
  }

  /// Shares the contact's tax code.
  void shareContact(Contact contact) {
    SharePlus.instance.share(ShareParams(text: contact.taxCode));
  }

  /// Navigates to the barcode page for the given contact.
  void showBarcodeForContact(BuildContext context, Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BarcodePage(taxCode: contact.taxCode)),
    );
  }

  @override
  void dispose() {
    // 3. È fondamentale smettere di ascoltare per evitare memory leak.
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