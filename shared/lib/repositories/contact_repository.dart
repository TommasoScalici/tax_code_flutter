import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/default_contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/database_service.dart';
import 'package:shared/services/local_cache_service.dart';
import 'package:shared/services/sync_service.dart';

export 'package:shared/repositories/contact_reconciler.dart';
export 'package:shared/repositories/default_contact_repository.dart';

/// Contract and factory interface for managing loading, caching,
/// reconciling, and mutating user contacts.
abstract class ContactRepository extends ChangeNotifier {
  /// Default factory constructor producing a [DefaultContactRepository].
  factory ContactRepository({
    required AuthService authService,
    required DatabaseService dbService,
    required LocalCacheService cacheService,
    required Logger logger,
    SyncService? syncService,
    bool autoInit,
  }) = DefaultContactRepository;

  /// Base constructor for implementations.
  ContactRepository.base();

  /// The immutable view of the user's contacts sorted by display index.
  List<Contact> get contacts;

  /// Whether contacts are actively being loaded from storage or network.
  bool get isLoading;

  /// Whether cloud synchronization is currently active.
  bool get isSyncActive;

  /// Initializes the repository explicitly by loading cached data and configuring
  /// remote synchronization listeners.
  Future<void> init();

  /// Adds or updates a single contact and persists the change to storage.
  Future<void> addOrUpdateContact(Contact contact);

  /// Removes a contact and persists the change to storage.
  Future<void> removeContact(Contact contact);

  /// Updates the complete list of contacts (e.g. after reordering) and persists.
  Future<void> updateContacts(List<Contact> contacts);

  /// Persists the full list of contacts to remote database and local cache.
  Future<void> saveContacts();
}
