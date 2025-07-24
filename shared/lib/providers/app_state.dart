import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

///
/// Manages the application's state, including authentication,
/// contacts, and theme settings.
///
final class AppState with ChangeNotifier {
  final _logger = Logger();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final SharedPreferencesAsync _prefs;
  StreamSubscription? _contactsSubscription;
  Completer<void>? _initCompleter;

  List<Contact> _contacts = [];
  String _currentTheme = 'light';
  User? _currentUser;
  bool _isSearching = false;
  bool _isLoading = true;

  List<Contact> get contacts => _contacts;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String get theme => _currentTheme;
  Future<void>? get initializationComplete => _initCompleter?.future;

  @visibleForTesting
  User? get currentUser => _currentUser;

  ///
  /// The main constructor for the application.
  /// Initializes the AppState by listening to authentication changes.
  ///
  AppState.main()
    : this(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        prefs: SharedPreferencesAsync(),
      );

  ///
  /// A special constructor for testing purposes to allow dependency injection.
  ///
  @visibleForTesting
  AppState({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required SharedPreferencesAsync prefs,
  }) : _auth = auth,
       _firestore = firestore,
       _prefs = prefs {
    _listenToAuthChanges();
    loadTheme();
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    super.dispose();
  }

  ///
  /// Adds a new contact or updates an existing one.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> addContact(Contact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);

    if (index != -1) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    _sortContacts();
    notifyListeners();

    await _addOrUpdateContactInFirebase(contact);
    await _saveContactsToLocalCache();
  }

  ///
  /// Removes a contact.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> removeContact(Contact contact) async {
    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();

    await _removeContactFromFirebase(contact);
    await _saveContactsToLocalCache();
  }

  ///
  /// Updates the local list of contacts, usually after a reorder operation,
  /// and persists the new order to Firestore and local cache.
  ///
  Future<void> updateContacts(List<Contact> contacts) async {
    _contacts = contacts;
    notifyListeners();
    await saveContacts();
  }

  ///
  /// Sets the searching state to show or hide search-specific UI.
  ///
  void setSearchState(bool searchState) {
    _isSearching = searchState;
    notifyListeners();
  }

  ///
  /// Toggles the application theme between light and dark mode.
  ///
  void toggleTheme() {
    _currentTheme = _currentTheme == 'dark' ? 'light' : 'dark';
    _saveTheme(_currentTheme);
    notifyListeners();
  }

  ///
  /// Persists the full list of contacts to Firestore and local cache.
  /// Ideal for operations that affect the entire list, like reordering.
  ///
  Future<void> saveContacts() async {
    if (_currentUser == null) return;
    await _saveContactsToFirebase();
    await _saveContactsToLocalCache();
  }

  ///
  /// Saves user metadata to Firestore upon login or registration.
  ///
  Future<void> saveUserData(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
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

  ///
  /// Loads the saved theme from shared preferences.
  ///
  Future<void> loadTheme() async {
    _currentTheme = await _prefs.getString('theme') ?? 'light';
    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async {
    await _prefs.setString('theme', theme);
  }

  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((user) {
      _isLoading = true;
      _contactsSubscription?.cancel();
      _initCompleter = Completer<void>();

      if (user == null) {
        _currentUser = null;
        _contacts = [];
        _isLoading = false;
        notifyListeners();
        if (!_initCompleter!.isCompleted) _initCompleter!.complete();
      } else {
        _currentUser = user;
        _initializeUserData();
      }
    });
  }

  Future<void> _initializeUserData() async {
    if (_currentUser == null) return;
    // The new logic starts listening to remote first.
    _listenToRemoteContacts();
  }

  void _listenToRemoteContacts() {
    if (_currentUser == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('contacts');

    _contactsSubscription = collection.snapshots().listen(
      (snapshot) {
        // Success path: data from Firestore is the source of truth.
        final remoteContacts = snapshot.docs
            .map((doc) => Contact.fromMap(doc.data()))
            .toList();
        _contacts = remoteContacts;
        _sortContacts();

        if (_isLoading) _isLoading = false;
        notifyListeners();

        // Update the cache with the fresh data.
        _saveContactsToLocalCache();

        if (!_initCompleter!.isCompleted) _initCompleter!.complete();
      },
      onError: (e) {
        // Error path: could be offline. Load from cache as a fallback.
        _logger.e(
          'Error listening to remote contacts: $e. Loading from cache.',
        );
        _loadContactsFromLocalCache().whenComplete(() {
          _isLoading = false;
          notifyListeners();
          if (!_initCompleter!.isCompleted) _initCompleter!.complete();
        });
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
        _sortContacts();
      }
    } on Exception catch (e) {
      _logger.e('Error loading contacts from local cache: $e');
      _contacts = [];
    }
  }

  Future<void> _saveContactsToLocalCache() async {
    if (_currentUser == null) return;
    try {
      final file = await _getLocalCacheFile();
      final contactsSerialized = json.encode(
        _contacts.map((c) => c.toJson()).toList(),
      );
      await file.writeAsString(contactsSerialized);
    } on Exception catch (e) {
      _logger.e('Error saving contacts to local cache: $e');
    }
  }

  Future<File> _getLocalCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/contacts_${_currentUser!.uid}.json');
  }

  Future<void> _addOrUpdateContactInFirebase(Contact contact) async {
    if (_currentUser == null) return;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('contacts')
          .doc(contact.id);
      await docRef.set(contact.toMap());
    } on Exception catch (e) {
      _logger.e('Error adding/updating contact in Firebase: $e');
    }
  }

  Future<void> _removeContactFromFirebase(Contact contact) async {
    if (_currentUser == null) return;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('contacts')
          .doc(contact.id);
      await docRef.delete();
    } on Exception catch (e) {
      _logger.e('Error removing contact from Firebase: $e');
    }
  }

  Future<void> _saveContactsToFirebase() async {
    if (_currentUser == null) return;
    try {
      final collection = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('contacts');
      final WriteBatch batch = _firestore.batch();
      final remoteSnapshot = await collection.get();
      final localIds = _contacts.map((contact) => contact.id).toSet();

      for (final doc in remoteSnapshot.docs) {
        if (!localIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }

      for (var i = 0; i < _contacts.length; i++) {
        final contactWithNewIndex = _contacts[i].copyWith(listIndex: i);
        _contacts[i] = contactWithNewIndex;
        batch.set(
          collection.doc(contactWithNewIndex.id),
          contactWithNewIndex.toMap(),
        );
      }

      await batch.commit();
    } on Exception catch (e) {
      _logger.e('Error while saving contacts to Firebase: $e');
    }
  }

  void _sortContacts() {
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
  }
}

///
/// Simple wrapper for SharedPreferences to make it easier to mock in tests.
///
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
