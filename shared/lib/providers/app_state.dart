import 'dart:async';
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

/// Manages the application's state, including authentication,
/// contacts, and theme settings.
final class AppState with ChangeNotifier {
  final _logger = Logger();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  StreamSubscription? _contactsSubscription;

  List<Contact> _contacts = [];
  String _currentTheme = 'light';
  User? _currentUser;
  bool _isSearching = false;
  bool _isLoading = true;

  List<Contact> get contacts => _contacts;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String get theme => _currentTheme;

  /// Initializes the AppState by listening to authentication changes.
  AppState() {
    _listenToAuthChanges();
    loadTheme();
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    super.dispose();
  }

  /// Adds a new contact to the local list and saves it to Firestore.
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    notifyListeners();
    await saveContacts();
  }

  /// Removes a contact from the local list and deletes it from Firestore.
  Future<void> removeContact(Contact contact) async {
    _contacts.remove(contact);
    notifyListeners();
    await saveContacts();
  }

  /// Updates the local list of contacts, usually after a reorder operation.
  void updateContacts(List<Contact> contacts) {
    _contacts = contacts;
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
    notifyListeners();
  }

  /// Sets the searching state to show or hide search-specific UI.
  void setSearchState(bool searchState) {
    _isSearching = searchState;
  }

  /// Toggles the application theme between light and dark mode.
  void toggleTheme() {
    _currentTheme = _currentTheme == 'dark' ? 'light' : 'dark';
    _saveTheme(_currentTheme);
    notifyListeners();
  }

  /// Persists all current contacts to Firestore and local cache.
  Future<void> saveContacts() async {
    if (_currentUser == null) return;
    await _saveContactsToFirebase();
    await _saveContactsToLocalCache();
  }

  /// Saves user metadata to Firestore upon login or registration.
  Future<void> saveUserData(User user) async {
    if (!await InternetConnection().hasInternetAccess) return;

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnapshot = await userRef.get();

      final userData = {
        'id': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (!userSnapshot.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userRef.set(userData, SetOptions(merge: true));
    } on Exception catch (e) {
      _logger.e('Error while storing user data: $e');
    }
  }

  /// Loads the saved theme from shared preferences.
  Future<void> loadTheme() async {
    _currentTheme = await _prefs.getString('theme') ?? 'light';
    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async {
    await _prefs.setString('theme', theme);
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _isLoading = true;
      _contactsSubscription?.cancel();

      if (user == null) {
        _currentUser = null;
        _contacts = [];
        _isLoading = false;
        notifyListeners();
      } else {
        _currentUser = user;
        _initializeUserData();
      }
    });
  }

  Future<void> _initializeUserData() async {
    if (_currentUser == null) return;

    if (await InternetConnection().hasInternetAccess) {
      _listenToRemoteContacts();
    } else {
      _logger.i('No internet connection. Loading contacts from local cache.');
      await _loadContactsFromLocalCache();
      notifyListeners();
    }
  }

  void _listenToRemoteContacts() {
    if (_currentUser == null) return;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('contacts');

    _contactsSubscription = collection.snapshots().listen(
      (snapshot) {
        final remoteContacts =
            snapshot.docs.map((doc) => Contact.fromMap(doc.data())).toList();
        remoteContacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
        _contacts = remoteContacts;
        _isLoading = false;
        notifyListeners();
        _saveContactsToLocalCache();
      },
      onError: (e) {
        _logger.e('Error listening to remote contacts: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadContactsFromLocalCache() async {
    try {
      final file = await _getLocalCacheFile();
      if (await file.exists()) {
        final contactsJson = await file.readAsString();
        final List<dynamic> contactsDeserialized = json.decode(contactsJson);
        _contacts = contactsDeserialized
            .map((json) => Contact.fromJson(json as Map<String, dynamic>))
            .toList();
        _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
      }
    } on Exception catch (e) {
      _logger.e('Error loading contacts from local cache: $e');
      _contacts = [];
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _saveContactsToLocalCache() async {
    if (_currentUser == null) return;
    try {
      final file = await _getLocalCacheFile();
      final contactsSerialized =
          json.encode(_contacts.map((c) => c.toJson()).toList());
      await file.writeAsString(contactsSerialized);
    } on Exception catch (e) {
      _logger.e('Error saving contacts to local cache: $e');
    }
  }

  Future<File> _getLocalCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/contacts_${_currentUser!.uid}.json');
  }

  Future<void> _saveContactsToFirebase() async {
    if (_currentUser == null || !await InternetConnection().hasInternetAccess) {
      return;
    }

    try {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('contacts');

      final WriteBatch batch = FirebaseFirestore.instance.batch();

      final remoteSnapshot = await collection.get();
      final localIds = _contacts.map((contact) => contact.id).toSet();

      for (final doc in remoteSnapshot.docs) {
        if (!localIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }

      for (final contact in _contacts) {
        batch.set(collection.doc(contact.id), contact.toMap());
      }

      await batch.commit();
    } on Exception catch (e) {
      _logger.e('Error while saving contacts to Firebase: $e');
    }
  }
}

/// Simple wrapper for SharedPreferences to make it easier to mock in tests.
class SharedPreferencesAsync {
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}
