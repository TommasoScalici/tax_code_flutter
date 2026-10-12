import 'dart:async';

import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/local_cache_service.dart';
import 'package:shared/services/sync_service.dart';

/// Default concrete implementation of [ContactRepository], managing loading,
/// local Hive caching, Firestore remote synchronization, and authentication changes.
class DefaultContactRepository extends ContactRepository {
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

  @override
  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  bool get isLoading => _isLoading;

  String? get _userId => _authService.currentUser?.uid;

  @override
  bool get isSyncActive =>
      _syncService?.isSyncEnabled ??
      (_authService.isSignedIn && !_authService.isGuest);

  /// Creates a [DefaultContactRepository].
  ///
  /// When [autoInit] is true (default), initializes data asynchronously on construction.
  /// When false, [init] must be called explicitly.
  DefaultContactRepository({
    required AuthService authService,
    required DatabaseService dbService,
    required LocalCacheService cacheService,
    required Logger logger,
    SyncService? syncService,
    bool autoInit = true,
  })  : _authService = authService,
        _dbService = dbService,
        _cacheService = cacheService,
        _logger = logger,
        _syncService = syncService,
        super.base() {
    _authService.addListener(_onAuthChanged);
    _syncService?.addListener(_onSyncStateChanged);

    if (autoInit) {
      unawaited(init());
    } else {
      _isLoading = false;
    }
  }

  @override
  Future<void> init() async {
    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      _cachedUserId = initialUser.uid;
      await _initializeUserData(initialUser.uid);
    } else {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
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

  Future<void> _reconcileLocalAndRemoteContacts(String userId) async {
    try {
      final remoteContacts = await _dbService.getContacts(userId);
      if (remoteContacts.isEmpty && _contacts.isEmpty) {
        return;
      }

      final mergedList = ContactReconciler.reconcileByTimestamp(
        remoteContacts: remoteContacts,
        localContacts: _contacts,
      );

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

  @override
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

  @override
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

  @override
  Future<void> updateContacts(List<Contact> contacts) async {
    final now = DateTime.now();
    _contacts = contacts;
    for (var i = 0; i < _contacts.length; i++) {
      _contacts[i] = _contacts[i].copyWith(listIndex: i, updatedAt: now);
    }

    if (_isDisposed) return;
    notifyListeners();

    await saveContacts();
  }

  @override
  Future<void> saveContacts() async {
    final uid = _userId ?? _cachedUserId;
    if (uid == null) return;
    if (isSyncActive) {
      try {
        await _dbService.saveAllContacts(uid, _contacts);
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
      final hadLocalOnlyContacts =
          _contactsSubscription == null && _contacts.isNotEmpty;
      final guestContactsToMigrate =
          hadLocalOnlyContacts ? List<Contact>.from(_contacts) : <Contact>[];

      await _contactsSubscription?.cancel();
      _contactsSubscription = null;

      if (user != null) {
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
      final remoteContacts = await _dbService.getContacts(targetUserId);

      final mergedContacts = ContactReconciler.mergeGuestIntoRemote(
        remoteContacts: remoteContacts,
        guestContacts: guestContacts,
      );

      _contacts = mergedContacts;

      await _dbService.saveAllContacts(targetUserId, _contacts);
      await _saveContactsToLocalCache();

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
    final uid = _cachedUserId ?? _userId;
    if (uid != null) {
      await _cacheService.saveContacts(uid, _contacts);
    }
  }
}
