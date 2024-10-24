import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

final class AppState with ChangeNotifier {
  final _logger = Logger();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  List<Contact> _contacts = [];
  bool _isSearching = false;
  String _currentTheme = '';

  List<Contact> get contacts => _contacts;
  bool get isSearching => _isSearching;
  String get theme => _currentTheme;
  Logger get logger => _logger;

  void addContact(Contact contact) {
    contacts.add(contact);
    notifyListeners();
  }

  void removeContact(Contact contact) {
    contacts.remove(contact);
    notifyListeners();
  }

  void updateContacts(List<Contact> contacts) {
    _contacts = contacts;
    _contacts.sort((x, y) => x.listIndex.compareTo(y.listIndex));
    notifyListeners();
  }

  void setSearchState(bool searchState) => _isSearching = searchState;

  void toggleTheme() {
    _currentTheme = _currentTheme == 'dark' ? 'light' : 'dark';
    _saveTheme(_currentTheme);
    notifyListeners();
  }

  Future<List<Contact>> loadContacts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && await InternetConnection().hasInternetAccess) {
        final userId = currentUser.uid;
        final contactsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('contacts');
        final querySnapshot = await contactsCollection.get();
        final contacts = querySnapshot.docs
            .map((doc) => Contact.fromMap(doc.data()))
            .toList();
        updateContacts(contacts);
        await _saveContactsOnLocal();
      } else {
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
      }
    } on Exception catch (e) {
      logger.e('Error while loading state: $e');
    }

    return _contacts;
  }

  Future<void> saveContacts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && await InternetConnection().hasInternetAccess) {
        final userId = currentUser.uid;
        var contactsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('contacts');

        final currentContactIds =
            contacts.map((contact) => contact.id).toList();
        final existingContactsSnapshot = await contactsCollection.get();

        for (var doc in existingContactsSnapshot.docs) {
          if (!currentContactIds.contains(doc.id)) {
            await doc.reference.delete();
          }
        }

        for (var contact in contacts) {
          await contactsCollection
              .doc(contact.id)
              .set(contact.toMap(), SetOptions(merge: true));
        }
      }
    } on Exception catch (e) {
      logger.e('Error while saving state on Firebase: $e');
    }

    await _saveContactsOnLocal();
  }

  Future<void> _saveContactsOnLocal() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/contacts.json');
      final contactsSerialized = json.encode(contacts);
      await file.writeAsString(contactsSerialized);
    } on Exception catch (e) {
      logger.e('Error while saving state on local storage: $e');
    }
  }

  Future<void> saveUserData(User user) async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final userRef = usersCollection.doc(user.uid);
      final userSnapshot = await userRef.get();

      final userData = {
        'id': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (!userSnapshot.exists ||
          !userSnapshot.data()!.containsKey('createdAt')) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userRef.set(userData, SetOptions(merge: true));
    } on Exception catch (e) {
      _logger.e('Error while storing user date: $e');
    }
  }

  Future<void> loadTheme() async {
    _currentTheme = await _prefs.getString('theme') ?? 'light';
    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async =>
      _prefs.setString('theme', theme);
}
