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

  String? _cachedUserId;
  StreamSubscription? _contactsSubscription;
  List<Contact> _contacts = [];
  bool _isDisposed = false;
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
  }) : _authService = authService,
       _dbService = dbService,
       _logger = logger {
    _authService.addListener(_onAuthChanged);

    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      _cachedUserId = initialUser.uid;
      _initializeUserData(initialUser.uid);
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authService.removeListener(_onAuthChanged);
    _contactsSubscription?.cancel();
    super.dispose();
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

    if (_isDisposed) return;
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

    if (_isDisposed) return;
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

    if (_isDisposed) return;
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

  ///
  /// Clears user data from the state and local cache on logout.
  ///
  Future<void> _clearUserData() async {
    final userIdToClear = _cachedUserId;
    if (userIdToClear != null) {
      try {
        final box = await Hive.openBox<Contact>('contacts_$userIdToClear');
        await box.clear();
        _logger.i('Local cache for user $userIdToClear has been cleared.');
      } on Exception catch (e, s) {
        _logger.e(
          'Failed to clear local cache for user $userIdToClear',
          error: e,
          stackTrace: s,
        );
      }
    }

    _contacts = [];
    _isLoading = false;
    _cachedUserId = null;
    if (_isDisposed) return;
    notifyListeners();
  }

  ///
  /// Loads initial contacts from remote or cache and sets up the listener.
  ///
  Future<void> _initializeUserData(String userId) async {
    _isLoading = true;
    if (_isDisposed) return;
    notifyListeners();

    try {
      final initialContacts = await _dbService
          .getContactsStream(userId)
          .first
          .timeout(const Duration(seconds: 10));
      // This method already sets isLoading = false and notifies listeners
      await _processContactsUpdate(initialContacts);
    } catch (e, s) {
      _logger.e(
        'Could not get initial contacts, falling back to cache.',
        error: e,
        stackTrace: s,
      );
      await _loadContactsFromLocalCache();
      _isLoading = false;
      if (_isDisposed) return;
      notifyListeners();
    }

    _listenToRemoteContacts(userId);
  }

  ///
  /// Listens to authentication changes and dispatches to the appropriate handler.
  ///
  Future<void> _onAuthChanged() async {
    final user = _authService.currentUser;

    // Act only if the user state has actually changed
    if (user?.uid != _cachedUserId) {
      await _contactsSubscription?.cancel();
      _contactsSubscription = null;

      if (user != null) {
        // A user has logged in or switched
        _cachedUserId = user.uid;
        await _initializeUserData(user.uid);
      } else {
        // The user has logged out
        await _clearUserData();
      }
    }
  }

  void _listenToRemoteContacts(String userId) {
    _contactsSubscription = _dbService
        .getContactsStream(userId)
        .listen(
          (remoteContacts) async {
            await _processContactsUpdate(remoteContacts);
          },
          onError: (e, s) {
            _logger.e(
              'Error on contacts stream after initial load.',
              error: e,
              stackTrace: s,
            );
          },
        );
  }

  Future<void> _processContactsUpdate(List<Contact> remoteContacts) async {
    _contacts = List.from(remoteContacts)
      ..sort((a, b) => a.listIndex.compareTo(b.listIndex));

    try {
      await _saveContactsToLocalCache();
    } on Exception catch (e, s) {
      _logger.e('Error saving contacts to Hive cache', error: e, stackTrace: s);
    }

    if (_isLoading) {
      _isLoading = false;
    }

    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> _loadContactsFromLocalCache() async {
    final box = await Hive.openBox<Contact>('contacts_$_cachedUserId');
    _contacts = box.values.toList();
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
  }

  Future<void> _saveContactsToLocalCache() async {
    final box = await Hive.openBox<Contact>('contacts_$_cachedUserId');
    await box.clear();
    await box.putAll({for (var c in _contacts) c.id: c});
  }
}
