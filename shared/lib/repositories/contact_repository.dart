import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/local_cache_service.dart';
import 'package:shared/services/sync_service.dart';

///
/// Manages loading, caching, and modifying user contacts.
///
class ContactRepository with ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _dbService;
  final LocalCacheService _cacheService;
  final Logger _logger;
  final SyncService? _syncService;

  String? _cachedUserId;
  StreamSubscription<List<Contact>>? _contactsSubscription;
  List<Contact> _contacts = [];
  bool _isDisposed = false;
  bool _isLoading = true;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get _userId => _authService.currentUser?.uid;

  /// Whether cloud sync is currently active.
  bool get isSyncActive =>
      _syncService?.isSyncEnabled ??
      (_authService.isSignedIn && !_authService.isGuest);

  ///
  /// The main constructor for the contact repository.
  /// It listens to authentication changes to load/clear data.
  ///
  ContactRepository({
    required AuthService authService,
    required DatabaseService dbService,
    required LocalCacheService cacheService,
    required Logger logger,
    SyncService? syncService,
  }) : _authService = authService,
       _dbService = dbService,
       _cacheService = cacheService,
       _logger = logger,
       _syncService = syncService {
    _authService.addListener(_onAuthChanged);
    _syncService?.addListener(_onSyncStateChanged);

    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      _cachedUserId = initialUser.uid;
      unawaited(_initializeUserData(initialUser.uid));
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authService.removeListener(_onAuthChanged);
    _syncService?.removeListener(_onSyncStateChanged);
    final subscription = _contactsSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  void _onSyncStateChanged() {
    unawaited(_handleSyncStateChanged());
  }

  Future<void> _handleSyncStateChanged() async {
    if (_isDisposed) return;
    if (isSyncActive) {
      if (_contactsSubscription == null && _userId != null) {
        final userId = _userId!;
        await _reconcileLocalAndRemoteContacts(userId);
        if (_isDisposed || !isSyncActive) return;
        _listenToRemoteContacts(userId);
      }
    } else {
      final subscription = _contactsSubscription;
      if (subscription != null) {
        await subscription.cancel();
        _contactsSubscription = null;
      }
      // Note: We deliberately do NOT wipe cloud contacts when sync is toggled off locally.
      // Cloud contacts remain safe for other devices, preventing accidental data loss.
    }
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Reconciles local and remote contacts non-destructively, resolving conflicts via [Contact.updatedAt].
  Future<void> _reconcileLocalAndRemoteContacts(String userId) async {
    try {
      final remoteContacts = await _dbService.getContacts(userId);
      if (remoteContacts.isEmpty && _contacts.isEmpty) {
        return;
      }

      final mergedMap = <String, Contact>{};

      // 1. Seed with remote contacts
      for (final remote in remoteContacts) {
        mergedMap[remote.id] = remote;
      }

      // 2. Merge local contacts with timestamp-based conflict resolution
      for (final local in _contacts) {
        final existing = mergedMap[local.id];
        if (existing == null) {
          // Contact exists only locally (created offline) -> keep it to upload
          mergedMap[local.id] = local;
        } else {
          // Contact exists in both -> compare updatedAt
          if (local.updatedAt != null && existing.updatedAt != null) {
            if (local.updatedAt!.isAfter(existing.updatedAt!)) {
              mergedMap[local.id] = local;
            }
          } else if (local.updatedAt != null) {
            mergedMap[local.id] = local;
          }
          // Otherwise existing (remote) is preserved
        }
      }

      final mergedList = mergedMap.values.toList();
      for (var i = 0; i < mergedList.length; i++) {
        mergedList[i] = mergedList[i].copyWith(listIndex: i);
      }
      mergedList.sort((a, b) => a.listIndex.compareTo(b.listIndex));

      _contacts = mergedList;
      await _dbService.saveAllContacts(userId, _contacts);
      await _saveContactsToLocalCache();
    } on Object catch (e, s) {
      _logger.e(
        'Error during local-remote contacts reconciliation',
        error: e,
        stackTrace: s,
      );
    }
  }

  ///
  /// Adds or update a contact.
  /// Persists the change to Firestore and local cache.
  ///
  Future<void> addOrUpdateContact(Contact contact) async {
    if (_userId == null) return;

    final stampedContact = contact.copyWith(updatedAt: DateTime.now());

    final index = _contacts.indexWhere((c) => c.id == stampedContact.id);
    if (index != -1) {
      _contacts[index] = stampedContact;
    } else {
      _contacts.add(stampedContact);
    }
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));

    if (_isDisposed) return;
    notifyListeners();

    if (isSyncActive) {
      try {
        await _dbService.addOrUpdateContact(_userId!, stampedContact);
      } on Exception catch (e, s) {
        _logger.e(
          'Error adding/updating contact in Firebase',
          error: e,
          stackTrace: s,
        );
      }
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

    if (isSyncActive) {
      try {
        await _dbService.removeContact(_userId!, contact.id);
      } on Exception catch (e, s) {
        _logger.e(
          'Error removing contact from Firebase',
          error: e,
          stackTrace: s,
        );
      }
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
    if (isSyncActive) {
      try {
        await _dbService.saveAllContacts(_userId!, _contacts);
      } on Exception catch (e, s) {
        _logger.e(
          'Error while saving contacts to Firebase',
          error: e,
          stackTrace: s,
        );
      }
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
        await _cacheService.clearContacts(userIdToClear);
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
      await _loadContactsFromLocalCache();
    } on Object catch (e, s) {
      _logger.e(
        'Could not load contacts from local cache.',
        error: e,
        stackTrace: s,
      );
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }

    if (isSyncActive) {
      _listenToRemoteContacts(userId);
    }
  }

  ///
  /// Listens to authentication changes and dispatches to the appropriate handler.
  ///
  void _onAuthChanged() {
    unawaited(
      _processAuthChange().catchError((Object error, StackTrace stackTrace) {
        _logger.e(
          'Unhandled error during auth change processing',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  Future<void> _processAuthChange() async {
    final user = _authService.currentUser;

    // Act only if the user state has actually changed
    if (user?.uid != _cachedUserId) {
      final previousUserId = _cachedUserId;
      // If we previously had contacts in a non-syncing (guest/offline) session and are now signing into an account
      final hadLocalOnlyContacts =
          _contactsSubscription == null && _contacts.isNotEmpty;
      final guestContactsToMigrate =
          hadLocalOnlyContacts ? List<Contact>.from(_contacts) : <Contact>[];

      await _contactsSubscription?.cancel();
      _contactsSubscription = null;

      if (user != null) {
        // A user has logged in or switched
        _cachedUserId = user.uid;

        if (guestContactsToMigrate.isNotEmpty && isSyncActive) {
          await _migrateGuestContactsToAccount(
            user.uid,
            guestContactsToMigrate,
            previousUserId,
          );
        } else {
          await _initializeUserData(user.uid);
        }
      } else {
        // The user has logged out
        await _clearUserData();
      }
    }
  }

  Future<void> _migrateGuestContactsToAccount(
    String targetUserId,
    List<Contact> guestContacts,
    String? previousUserId,
  ) async {
    _isLoading = true;
    if (_isDisposed) return;
    notifyListeners();

    try {
      // 1. Fetch remote contacts for the target user (if any exist on the cloud)
      final remoteContacts = await _dbService.getContacts(targetUserId);

      // 2. Perform intelligent merge: preserve remote contacts, add guest contacts if not already present
      final mergedContacts = List<Contact>.from(remoteContacts);
      final existingTaxCodes =
          mergedContacts.map((c) => c.taxCode.toUpperCase()).toSet();
      final existingIds = mergedContacts.map((c) => c.id).toSet();

      for (final guestContact in guestContacts) {
        final taxCodeUpper = guestContact.taxCode.toUpperCase();
        if (!existingTaxCodes.contains(taxCodeUpper) &&
            !existingIds.contains(guestContact.id)) {
          mergedContacts.add(guestContact);
          existingTaxCodes.add(taxCodeUpper);
          existingIds.add(guestContact.id);
        }
      }

      // 3. Re-index merged contacts
      for (var i = 0; i < mergedContacts.length; i++) {
        mergedContacts[i] = mergedContacts[i].copyWith(listIndex: i);
      }

      _contacts = mergedContacts;

      // 4. Save merged contacts to Firestore so cloud has the complete unified list
      await _dbService.saveAllContacts(targetUserId, _contacts);

      // 5. Save to local cache for the target user
      await _saveContactsToLocalCache();

      // 6. Clean up the old guest local cache
      if (previousUserId != null) {
        try {
          await _cacheService.clearContacts(previousUserId);
        } on Object catch (e, s) {
          _logger.e(
            'Failed to clear migrated guest cache',
            error: e,
            stackTrace: s,
          );
        }
      }
    } on Object catch (e, s) {
      _logger.e(
        'Error during guest contact migration to user $targetUserId',
        error: e,
        stackTrace: s,
      );
      await _initializeUserData(targetUserId);
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }

    // 7. Attach the remote stream listener to keep synced with cloud
    if (isSyncActive) {
      _listenToRemoteContacts(targetUserId);
    }
  }

  void _listenToRemoteContacts(String userId) {
    _contactsSubscription = _dbService
        .getContactsStream(userId)
        .listen(
          (remoteContacts) async {
            await _processContactsUpdate(remoteContacts);
          },
          onError: (Object e, StackTrace s) {
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
    _contacts = await _cacheService.loadContacts(_cachedUserId!);
    _contacts.sort((a, b) => a.listIndex.compareTo(b.listIndex));
  }

  Future<void> _saveContactsToLocalCache() async {
    await _cacheService.saveContacts(_cachedUserId!, _contacts);
  }
}
