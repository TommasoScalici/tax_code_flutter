import 'package:flutter/foundation.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';

class FakeContactRepository extends ChangeNotifier
    implements ContactRepository {
  
  bool _isLoading = false;
  List<Contact> _contacts = [];

  @override
  bool get isLoading => _isLoading;
  @override
  List<Contact> get contacts => _contacts;

  void setState({bool? loading, List<Contact>? newContacts}) {
    if (loading != null) _isLoading = loading;
    if (newContacts != null) _contacts = newContacts;
    notifyListeners();
  }
  
  @override
  Future<void> addOrUpdateContact(Contact contact) async {}
  @override
  Future<void> removeContact(Contact contact) async {}
  @override
  Future<void> saveContacts() async {}
  @override
  Future<void> updateContacts(List<Contact> contacts) async {}
}