import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

final class AppState with ChangeNotifier {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final List<Contact> _contacts = [];

  List<Contact> get contacts => _contacts;
  SharedPreferencesAsync get prefs => _prefs;

  void addContact(Contact contact) {
    contacts.add(contact);
    notifyListeners();
  }
}
