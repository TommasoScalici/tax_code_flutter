import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/providers/shared_preferences_async.dart';
import 'package:shared/services/database_service.dart';

import '../models/contact.dart';

///
/// Manages the application's state, including authentication,
/// contacts, and theme settings.
///
class AppState with ChangeNotifier {
  final DatabaseService _dbService;
  final FirebaseAuth _auth;
  final Logger _logger;
  final SharedPreferencesAsync _prefs;

  StreamSubscription? _contactsSubscription;
  Completer<void>? _initCompleter;

  List<Contact> _contacts = [];
  String _currentTheme = 'light';
  User? _currentUser;
  bool _isLoading = true;
  bool _isSearching = false;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isSignedIn => _currentUser != null;
  String get theme => _currentTheme;
  Future<void>? get initializationComplete => _initCompleter?.future;

  @visibleForTesting
  User? get currentUser => _currentUser;

  ///
  /// The main constructor for the application.
  /// Initializes the AppState by listening to authentication changes.
  ///
  AppState.main()
    : _auth = FirebaseAuth.instance,
      _dbService = DatabaseService(firestore: FirebaseFirestore.instance),
      _logger = Logger(),
      _prefs = SharedPreferencesAsync() {
    _listenToAuthChanges();
    loadTheme();
  }

  ///
  /// A special constructor for testing purposes to allow dependency injection.
  ///
  @visibleForTesting
  AppState.withMocks({
    required FirebaseAuth auth,
    required DatabaseService dbService,
    required Logger logger,
    required SharedPreferencesAsync prefs,
  }) : _auth = auth,
       _dbService = dbService,
       _prefs = prefs,
       _logger = logger {
    _listenToAuthChanges();
    loadTheme();
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    super.dispose();
  }

  ///
  /// Signs the current user out.
  ///
  Future<void> signOut() async {
    await _auth.signOut();
  }

  ///
  /// Adds a new contact or updates an existing one.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> addContact(Contact contact) async {
    if (_currentUser == null) return;

    final index = _contacts.indexWhere((c) => c.id == contact.id);

    if (index != -1) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    _sortContacts();
    notifyListeners();

    try {
      await _dbService.addOrUpdateContact(_currentUser!.uid, contact);
    } on Exception catch (e, s) {
      _logger.e(
        'Error adding/updating contact in Firebase',
        error: e,
        stackTrace: s,
      );
    }
    await _saveContactsToLocalCache();
  }

  ///
  /// Removes a contact.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> removeContact(Contact contact) async {
    if (_currentUser == null) return;

    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();

    try {
      await _dbService.removeContact(_currentUser!.uid, contact.id);
    } on Exception catch (e, s) {
      _logger.e(
        'Error removing contact from Firebase',
        error: e,
        stackTrace: s,
      );
    }
    await _saveContactsToLocalCache();
  }

  ///
  /// Updates the local list of contacts, usually after a reorder operation,
  /// and persists the new order to Firestore and local cache.
  ///
  Future<void> updateContacts(List<Contact> contacts) async {
    _contacts = contacts;
    for (var i = 0; i < _contacts.length; i++) {
      _contacts[i] = _contacts[i].copyWith(listIndex: i);
    }
    notifyListeners();
    await saveContacts();
  }

  ///
  /// Persists the full list of contacts to Firestore and local cache.
  /// Ideal for operations that affect the entire list, like reordering.
  ///
  Future<void> saveContacts() async {
    if (_currentUser == null) return;
    try {
      await _dbService.saveAllContacts(_currentUser!.uid, _contacts);
    } on Exception catch (e, s) {
      _logger.e(
        'Error while saving contacts to Firebase',
        error: e,
        stackTrace: s,
      );
    }
    await _saveContactsToLocalCache();
  }

  ///
  /// Saves user metadata to Firestore upon login or registration.
  ///
  Future<void> saveUserData(User user) async {
    try {
      await _dbService.saveUserData(user);
    } on Exception catch (e, s) {
      _logger.e('Error while storing user data', error: e, stackTrace: s);
    }
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
      notifyListeners();

      if (user == null) {
        _onUserSignedOut();
      } else {
        _onUserSignedIn(user);
      }
    });
  }

  void _onUserSignedIn(User user) {
    _currentUser = user;
    saveUserData(user);
    _listenToRemoteContacts();
  }

  void _onUserSignedOut() {
    _currentUser = null;
    _contacts = [];
    _isLoading = false;
    notifyListeners();
    if (_initCompleter?.isCompleted == false) {
      _initCompleter!.complete();
    }
  }

  void _sortContacts() {
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
  }

  void _listenToRemoteContacts() {
    if (_currentUser == null) return;

    _contactsSubscription = _dbService
        .getContactsStream(_currentUser!.uid)
        .listen(
          (remoteContacts) {
            _contacts = remoteContacts;
            _sortContacts();
            _finishLoading();
            _saveContactsToLocalCache();
          },
          onError: (e, s) {
            _logger.e(
              'Error listening to remote contacts. Loading from cache',
              error: e,
              stackTrace: s,
            );
            _loadContactsFromLocalCache().whenComplete(() => _finishLoading());
          },
        );
  }

  void _finishLoading() {
    if (_isLoading) _isLoading = false;
    notifyListeners();
    if (_initCompleter?.isCompleted == false) {
      _initCompleter!.complete();
    }
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
    } on Exception catch (e, s) {
      _logger.e(
        'Error loading contacts from local cache',
        error: e,
        stackTrace: s,
      );
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
    } on Exception catch (e, s) {
      _logger.e(
        'Error saving contacts to local cache',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<File> _getLocalCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/contacts_${_currentUser!.uid}.json');
  }
}
