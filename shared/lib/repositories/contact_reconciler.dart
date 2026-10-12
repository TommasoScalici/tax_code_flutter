import 'package:shared/models/contact.dart';

/// Pure algorithmic utility for reconciling and merging contact lists
/// across local cache and remote cloud databases.
abstract final class ContactReconciler {
  /// Reconciles local and remote contacts non-destructively, resolving conflicts
  /// via [Contact.updatedAt].
  ///
  /// Rules:
  /// - If a contact exists only remotely, it is retained.
  /// - If a contact exists only locally, it is retained.
  /// - If a contact exists in both, the one with the latest [Contact.updatedAt] wins.
  ///   If both have null [Contact.updatedAt], remote is preserved.
  /// - The final list is sorted by [Contact.listIndex] and re-indexed sequentially (0..n).
  static List<Contact> reconcileByTimestamp({
    required List<Contact> remoteContacts,
    required List<Contact> localContacts,
  }) {
    if (remoteContacts.isEmpty && localContacts.isEmpty) {
      return const [];
    }

    final mergedMap = <String, Contact>{};

    // 1. Seed with remote contacts
    for (final remote in remoteContacts) {
      mergedMap[remote.id] = remote;
    }

    // 2. Merge local contacts with timestamp-based conflict resolution
    for (final local in localContacts) {
      final existing = mergedMap[local.id];
      if (existing == null) {
        // Contact exists only locally (created offline) -> keep it
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

    final mergedList = mergedMap.values.toList()
      ..sort((a, b) => a.listIndex.compareTo(b.listIndex));

    for (var i = 0; i < mergedList.length; i++) {
      mergedList[i] = mergedList[i].copyWith(listIndex: i);
    }

    return mergedList;
  }

  /// Merges guest/offline contacts into remote account contacts.
  ///
  /// Rules:
  /// - Remote contacts are preserved with highest priority.
  /// - Guest contacts are added only if their tax code (case-insensitive) and ID
  ///   are not already present in the remote set.
  /// - The merged list is sorted by [Contact.listIndex] and re-indexed sequentially (0..n).
  static List<Contact> mergeGuestIntoRemote({
    required List<Contact> remoteContacts,
    required List<Contact> guestContacts,
  }) {
    final sortedRemoteContacts = List<Contact>.from(remoteContacts)
      ..sort((a, b) => a.listIndex.compareTo(b.listIndex));
    final sortedGuestContacts = List<Contact>.from(guestContacts)
      ..sort((a, b) => a.listIndex.compareTo(b.listIndex));

    final mergedContacts = List<Contact>.from(sortedRemoteContacts);
    final existingTaxCodes =
        mergedContacts.map((c) => c.taxCode.toUpperCase()).toSet();
    final existingIds = mergedContacts.map((c) => c.id).toSet();

    for (final guestContact in sortedGuestContacts) {
      final taxCodeUpper = guestContact.taxCode.toUpperCase();
      if (!existingTaxCodes.contains(taxCodeUpper) &&
          !existingIds.contains(guestContact.id)) {
        mergedContacts.add(guestContact);
        existingTaxCodes.add(taxCodeUpper);
        existingIds.add(guestContact.id);
      }
    }

    for (var i = 0; i < mergedContacts.length; i++) {
      mergedContacts[i] = mergedContacts[i].copyWith(listIndex: i);
    }

    return mergedContacts;
  }
}
