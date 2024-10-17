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
  ThemeData _currentTheme = _getLightTheme();

  List<Contact> get contacts => _contacts;
  bool get isSearching => _isSearching;
  ThemeData get theme => _currentTheme;
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
    if (_currentTheme.brightness == Brightness.dark) {
      _currentTheme = _getLightTheme();
      _saveTheme('light');
    } else {
      _currentTheme = _getDarkTheme();
      _saveTheme('dark');
    }
    notifyListeners();
  }

  static ThemeData _getLightTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0),
            brightness: Brightness.light));
  }

  static ThemeData _getDarkTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0),
            brightness: Brightness.dark));
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

  Future<void> _loadTheme() async {
    final theme = await _prefs.getString('theme') ?? 'light';

    if (theme == 'dark') {
      _currentTheme = _getDarkTheme();
    } else {
      _currentTheme = _getLightTheme();
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

  Future<void> _saveTheme(String theme) async =>
      _prefs.setString('theme', theme);
}
