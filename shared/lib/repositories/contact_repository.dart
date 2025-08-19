import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';

///
/// Manages loading, caching, and modifying user contacts.
///
class ContactRepository with ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _dbService;
  final Logger _logger;

  StreamSubscription? _contactsSubscription;
  List<Contact> _contacts = [];
  bool _isLoading = true;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get _userId => _authService.currentUser?.uid;

  ///
  /// The main constructor for the contact repository.
  /// It listens to authentication changes to load/clear data.
  ///
  ContactRepository({
    required AuthService authService,
    required DatabaseService dbService,
    required Logger logger,
  })  : _authService = authService,
        _dbService = dbService,
        _logger = logger {
    _authService.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    _contactsSubscription?.cancel();

    if (_authService.isSignedIn) {
      _isLoading = true;
      notifyListeners();
      _listenToRemoteContacts();
    } else {
      _contacts = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _contactsSubscription?.cancel();
    super.dispose();
  }

  void _listenToRemoteContacts() {
    _contactsSubscription = _dbService.getContactsStream(_userId!).listen(
      (remoteContacts) async {
        _contacts = List.from(remoteContacts)
          ..sort((a, b) => a.listIndex.compareTo(b.listIndex));
        try {
          await _saveContactsToLocalCache();
        } on Exception catch (e, s) {
          _logger.e('Error saving contacts to Hive cache',
              error: e, stackTrace: s);
        }
        _finishLoading();
      },
      onError: (e, s) async {
        _logger.e(
          'Error listening to remote contacts. Loading from cache',
          error: e,
          stackTrace: s,
        );
        try {
          await _loadContactsFromLocalCache();
        } on Exception catch (e, s) {
          _logger.e('Failed to load contacts from Hive cache as well.',
              error: e, stackTrace: s);
          _contacts = [];
        }
        _finishLoading();
      },
    );
  }

  ///
  /// Adds or update a contact.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> addOrUpdateContact(Contact contact) async {
    if (_userId == null) return;

    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
    notifyListeners();

    try {
      await _dbService.addOrUpdateContact(_userId!, contact);
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
    if (_userId == null) return;

    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();

    try {
      await _dbService.removeContact(_userId!, contact.id);
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
    if (_userId == null) return;
    try {
      await _dbService.saveAllContacts(_userId!, _contacts);
    } on Exception catch (e, s) {
      _logger.e(
        'Error while saving contacts to Firebase',
        error: e,
        stackTrace: s,
      );
    }
    await _saveContactsToLocalCache();
  }

  Future<void> _loadContactsFromLocalCache() async {
    final box = await Hive.openBox<Contact>('contacts_$_userId');
    _contacts = box.values.toList();
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
  }

  Future<void> _saveContactsToLocalCache() async {
    final box = await Hive.openBox<Contact>('contacts_$_userId');
    await box.clear();
    await box.putAll({for (var c in _contacts) c.id: c});
  }

  void _finishLoading() {
    if (_isLoading) _isLoading = false;
    notifyListeners();
  }
}
