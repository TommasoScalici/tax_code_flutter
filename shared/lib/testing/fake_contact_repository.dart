import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/testing/test_contact_fixtures.dart';

/// Centralized in-memory fake implementation of [ContactRepository]
/// for widget tests and UI previews.
class FakeContactRepository extends ChangeNotifier
    implements ContactRepository {
  List<Contact> _contacts;
  bool _isLoading = false;
  bool _isSyncActive = false;

  /// Creates a [FakeContactRepository] populated with optional initial contacts.
  FakeContactRepository([List<Contact>? initialContacts])
    : _contacts = List<Contact>.from(
        initialContacts ?? TestContactFixtures.sampleContacts,
      );

  @override
  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isSyncActive => _isSyncActive;

  @override
  Future<void> init() async {}

  @override
  Future<void> addOrUpdateContact(Contact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    notifyListeners();
  }

  @override
  Future<void> removeContact(Contact contact) async {
    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }

  @override
  Future<void> updateContacts(List<Contact> contacts) async {
    _contacts = List<Contact>.from(contacts);
    notifyListeners();
  }

  @override
  Future<void> saveContacts() async {}

  /// Sets the simulated loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets the simulated sync active state.
  void setSyncActive(bool syncActive) {
    _isSyncActive = syncActive;
    notifyListeners();
  }

  /// Replaces the internal contact list.
  void setContacts(List<Contact> contacts) {
    _contacts = List<Contact>.from(contacts);
    notifyListeners();
  }
}
