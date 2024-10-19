import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

final class AppState with ChangeNotifier {
  final _logger = Logger();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  List<Contact> _contacts = [];
  bool _isSearching = false;
  String _currentTheme = 'light';

  List<Contact> get contacts => _contacts;
  bool get isSearching => _isSearching;
  String get theme => _currentTheme;
  Logger get logger => _logger;

  AppState() {
    _loadContacts();
    _loadTheme();
  }

  void addContact(Contact contact) {
    contacts.add(contact);
    notifyListeners();
  }

  void editContact(Contact contact, String oldContact) {
    final contactToEdit = contacts.where((c) => c.id == oldContact).first;
    final index = _contacts.indexOf(contactToEdit);
    contacts.removeAt(index);
    contacts.insert(index, contact);
    notifyListeners();
  }

  void removeContact(Contact contact) {
    contacts.remove(contact);
    notifyListeners();
  }

  void updateContacts(List<Contact> contacts) {
    _contacts = contacts;
    notifyListeners();
  }

  void setSearchState(bool searchState) => _isSearching = searchState;

  void toggleTheme() {
    if (_currentTheme == 'dark') {
      _currentTheme = 'light';
      _saveTheme('light');
    } else {
      _currentTheme = 'dark';
      _saveTheme('dark');
    }
    notifyListeners();
  }

  Future<void> _loadContacts() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/contacts.json');

      if (await file.exists()) {
        final contactsSerialized = await file.readAsString();
        List<dynamic> contactsDeserialized = json.decode(contactsSerialized);
        List<Contact> contacts = contactsDeserialized
            .map((json) => Contact.fromJson(json as Map<String, dynamic>))
            .toList();
        updateContacts(contacts);
      }
    } on Exception catch (e) {
      logger.e('Error while loading state: $e');
    }
  }

  Future<void> saveContacts() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/contacts.json');
      final contactsSerialized = json.encode(contacts);
      await file.writeAsString(contactsSerialized);
    } on Exception catch (e) {
      logger.e('Error while saving state: $e');
    }
  }

  Future _loadTheme() async => await _prefs.getString('theme') ?? 'light';

  Future _saveTheme(String theme) async => _prefs.setString('theme', theme);
}
