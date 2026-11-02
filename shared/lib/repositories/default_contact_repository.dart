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
  /// Storage identifier for local-only guest mode contacts in cache.
  static const String guestUserId = 'guest';

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

  String? get _effectiveUserId =>
      _authService.isGuest ? guestUserId : _authService.currentUser?.uid;

  @override
  bool get isSyncActive =>
      (_syncService?.isSyncEnabled ?? true) &&
      _authService.isSignedIn &&
      !_authService.isGuest;

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
  }) : _authService = authService,
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
    final effectiveId = _effectiveUserId;
    if (effectiveId != null) {
      _cachedUserId = effectiveId;
      await _initializeUserData(effectiveId);
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
      final effectiveId = _effectiveUserId;
      if (_contactsSubscription == null &&
          effectiveId != null &&
          effectiveId != guestUserId) {
        await _reconcileLocalAndRemoteContacts(effectiveId);
        if (_isDisposed || !isSyncActive) return;
        _listenToRemoteContacts(effectiveId);
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

      _contacts = List<Contact>.from(mergedList);
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
    final uid = _cachedUserId ?? _effectiveUserId;
    if (uid == null) return;

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

    if (isSyncActive && uid != guestUserId) {
      try {
        await _dbService.addOrUpdateContact(uid, stampedContact);
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
    final uid = _cachedUserId ?? _effectiveUserId;
    if (uid == null) return;

    _contacts.removeWhere((c) => c.id == contact.id);

    if (_isDisposed) return;
    notifyListeners();

    if (isSyncActive && uid != guestUserId) {
      try {
        await _dbService.removeContact(uid, contact.id);
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
    _contacts = List<Contact>.from(contacts);
    for (var i = 0; i < _contacts.length; i++) {
      _contacts[i] = _contacts[i].copyWith(listIndex: i, updatedAt: now);
    }

    if (_isDisposed) return;
    notifyListeners();

    await saveContacts();
  }

  @override
  Future<void> saveContacts() async {
    final uid = _cachedUserId ?? _effectiveUserId;
    if (uid == null) return;
    if (isSyncActive && uid != guestUserId) {
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
    if (userIdToClear != null && userIdToClear != guestUserId) {
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
        'Failed to initialize user data for $userId',
        error: e,
        stackTrace: s,
      );
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }

    if (isSyncActive && userId != guestUserId) {
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
    final currentId = _effectiveUserId;

    // Act only if the user state has actually changed
    if (currentId != _cachedUserId) {
      final previousUserId = _cachedUserId;
      final hadLocalOnlyContacts =
          _contactsSubscription == null && _contacts.isNotEmpty;
      final guestContactsToMigrate = hadLocalOnlyContacts
          ? List<Contact>.from(_contacts)
          : <Contact>[];

      await _contactsSubscription?.cancel();
      _contactsSubscription = null;

      if (currentId != null) {
        _cachedUserId = currentId;

        if (previousUserId == guestUserId &&
            currentId != guestUserId &&
            guestContactsToMigrate.isNotEmpty &&
            isSyncActive) {
          await _migrateGuestContactsToAccount(
            currentId,
            guestContactsToMigrate,
            previousUserId,
          );
        } else {
          await _initializeUserData(currentId);
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

      _contacts = List<Contact>.from(mergedContacts);

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

    if (isSyncActive && targetUserId != guestUserId) {
      _listenToRemoteContacts(targetUserId);
    }
  }

  void _listenToRemoteContacts(String userId) {
    if (userId == guestUserId || !isSyncActive) return;
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
    final uid = _cachedUserId ?? _effectiveUserId;
    if (uid != null) {
      await _cacheService.saveContacts(uid, _contacts);
    }
  }
}
