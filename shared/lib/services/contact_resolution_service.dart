import 'package:shared/models/contact.dart';

/// Service responsible for resolving contacts from queries or deep links,
/// implementing the 3-level identity resolution strategy for "Il mio codice fiscale".
final class ContactResolutionService {
  const ContactResolutionService();

  /// Resolves the primary contact representing the device owner ("Il mio codice fiscale")
  /// using a 3-level priority strategy:
  ///
  /// 1. **Explicit Contact (Level 1):** Contact marked with `isMe == true`.
  /// 2. **Account Display Name Match (Level 2):** Fallback matching [userDisplayName]
  ///    from the authenticated provider against `firstName` and `lastName`.
  /// 3. **Single Contact Fallback (Level 3):** If [contacts] contains exactly one contact,
  ///    returns that contact.
  ///
  /// Returns `null` if no unambiguous primary contact can be determined.
  Contact? resolvePrimaryContact(
    Iterable<Contact> contacts, {
    String? userDisplayName,
  }) {
    final list = contacts.toList(growable: false);
    if (list.isEmpty) return null;

    // Level 1: Explicit isMe flag
    for (final contact in list) {
      if (contact.isMe) return contact;
    }

    // Level 2: Match by user display name (if authenticated)
    if (userDisplayName != null && userDisplayName.trim().isNotEmpty) {
      final matched = _matchByDisplayName(list, userDisplayName.trim());
      if (matched != null) return matched;
    }

    // Level 3: Fallback on single contact in the app
    if (list.length == 1) {
      return list.first;
    }

    return null;
  }

  /// Resolves a contact based on an optional [id] or text [query],
  /// falling back to [resolvePrimaryContact] when the query indicates "me".
  Contact? resolveContact(
    Iterable<Contact> contacts, {
    String? id,
    String? query,
    String? userDisplayName,
  }) {
    final list = contacts.toList(growable: false);
    if (list.isEmpty) return null;

    // 1. Resolve by exact ID if provided
    if (id != null && id.trim().isNotEmpty) {
      final trimmedId = id.trim();
      for (final contact in list) {
        if (contact.id == trimmedId) return contact;
      }
    }

    // 2. Query empty or refers to "me" / "io" / "mio"
    final trimmedQuery = query?.trim();
    if (trimmedQuery == null ||
        trimmedQuery.isEmpty ||
        _isMeQuery(trimmedQuery)) {
      return resolvePrimaryContact(list, userDisplayName: userDisplayName);
    }

    // 3. Exact tax code match
    final upperQuery = trimmedQuery.toUpperCase();
    for (final contact in list) {
      if (contact.taxCode.toUpperCase() == upperQuery) {
        return contact;
      }
    }

    // 4. Name / substring search
    final normalizedQuery = _normalize(trimmedQuery);
    final matchingContacts = list.where((contact) {
      final fullName = _normalize('${contact.firstName} ${contact.lastName}');
      final reversedFullName = _normalize(
        '${contact.lastName} ${contact.firstName}',
      );
      final taxCode = contact.taxCode.toLowerCase();
      return fullName.contains(normalizedQuery) ||
          reversedFullName.contains(normalizedQuery) ||
          taxCode.contains(normalizedQuery);
    }).toList();

    if (matchingContacts.length == 1) {
      return matchingContacts.first;
    }

    if (matchingContacts.length > 1) {
      // Prioritize the primary contact if it is among the matches
      for (final contact in matchingContacts) {
        if (contact.isMe) return contact;
      }
      return matchingContacts.first;
    }

    return null;
  }

  bool _isMeQuery(String query) {
    final normalized = _normalize(query);
    return normalized == 'me' ||
        normalized == 'io' ||
        normalized == 'mio' ||
        normalized == 'il mio' ||
        normalized == 'my' ||
        normalized == 'myself';
  }

  Contact? _matchByDisplayName(List<Contact> contacts, String displayName) {
    final normalizedDisplay = _normalize(displayName);
    final displayTokens = normalizedDisplay
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (displayTokens.isEmpty) return null;

    final exactMatches = <Contact>[];
    final partialMatches = <Contact>[];

    for (final contact in contacts) {
      final normFirst = _normalize(contact.firstName);
      final normLast = _normalize(contact.lastName);

      final fullName = '$normFirst $normLast';
      final reversedFullName = '$normLast $normFirst';

      if (fullName == normalizedDisplay ||
          reversedFullName == normalizedDisplay) {
        exactMatches.add(contact);
        continue;
      }

      final firstTokens = normFirst.split(RegExp(r'\s+'));
      final lastTokens = normLast.split(RegExp(r'\s+'));

      final matchesLast = lastTokens.any(displayTokens.contains);
      final matchesFirst = firstTokens.any(displayTokens.contains);

      if (matchesLast && matchesFirst) {
        partialMatches.add(contact);
      }
    }

    if (exactMatches.length == 1) return exactMatches.first;
    if (exactMatches.isEmpty && partialMatches.length == 1) {
      return partialMatches.first;
    }

    return null;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp('[àáâãäå]'), 'a')
        .replaceAll(RegExp('[èéêë]'), 'e')
        .replaceAll(RegExp('[ìíîï]'), 'i')
        .replaceAll(RegExp('[òóôõö]'), 'o')
        .replaceAll(RegExp('[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
