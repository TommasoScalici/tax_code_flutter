import 'package:flutter/foundation.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';

/// A fake implementation of [ContactRepository] for testing purposes.
/// It extends [ChangeNotifier] to allow simulating state changes.
class FakeContactRepository extends ChangeNotifier implements ContactRepository {
  int listenerCount = 0;

  List<Contact> _contacts = [];
  bool _isLoading = false;

  @override
  List<Contact> get contacts => _contacts;

  @override
  bool get isLoading => _isLoading;

  /// A test helper to manually update the state and notify listeners.
  void setState({required List<Contact> contacts, bool isLoading = false}) {
    _contacts = contacts;
    _isLoading = isLoading;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    listenerCount++;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    listenerCount--;
  }
  
  // Implement other methods from the interface
  @override
  Future<void> addOrUpdateContact(Contact contact) async {}
  @override
  Future<void> removeContact(Contact contact) async {}
  @override
  Future<void> saveContacts() async {}
  @override
  Future<void> updateContacts(List<Contact> contacts) async {}
}