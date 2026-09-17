import 'package:shared/models/birthplace.dart';

/// Utility class for performing smart, relevance-ranked searches over a list of [Birthplace]s.
abstract final class BirthplaceSearchFilter {
  /// Normalizes input string by converting to lower case, stripping diacritics/accents,
  /// replacing punctuation with spaces, and trimming duplicate whitespace.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp('[àáâãäå]'), 'a')
        .replaceAll(RegExp('[èéêë]'), 'e')
        .replaceAll(RegExp('[ìíîï]'), 'i')
        .replaceAll(RegExp('[òóôõö]'), 'o')
        .replaceAll(RegExp('[ùúûü]'), 'u')
        .replaceAll(RegExp(r"['’\-\/\\,()]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculates the Damerau-Levenshtein distance between [s1] and [s2].
  /// Supports insertions, deletions, substitutions, and adjacent transpositions.
  static int damerauLevenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;

    final d = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
      growable: false,
    );

    for (var i = 0; i <= len1; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      d[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        var minVal = d[i - 1][j] + 1; // deletion
        final insertion = d[i][j - 1] + 1;
        if (insertion < minVal) minVal = insertion;
        final substitution = d[i - 1][j - 1] + cost;
        if (substitution < minVal) minVal = substitution;

        // transposition
        if (i > 1 &&
            j > 1 &&
            s1[i - 1] == s2[j - 2] &&
            s1[i - 2] == s2[j - 1]) {
          final transposition = d[i - 2][j - 2] + cost;
          if (transposition < minVal) minVal = transposition;
        }

        d[i][j] = minVal;
      }
    }

    return d[len1][len2];
  }

  /// Computes the relevance score for a municipality given its normalized fields and [cleanQuery].
  /// Higher scores indicate greater relevance.
  static int computeScore({
    required String normName,
    required String normState,
    required String normFull,
    required List<String> words,
    required String cleanQuery,
  }) {
    // 1. Exact match on municipality name (highest priority)
    if (normName == cleanQuery) return 10000;

    // 2. Full combined match: e.g. "Roma RM" or "Roma (RM)"
    if (normFull == cleanQuery) return 9000;

    // 3. Name starts with query (prefix match)
    if (normName.startsWith(cleanQuery)) return 5000;

    // 4. Combined string starts with query: e.g. "Roma R" -> "Roma (RM)"
    if (normFull.startsWith(cleanQuery)) return 4500;

    // 5. Any distinct word in the name starts with the query (e.g. "Roma" in "Campagnano di Roma")
    for (final word in words) {
      if (word.startsWith(cleanQuery)) return 2500;
    }

    // 6. Substring containment inside the name (e.g. "roma" in "Casalromano")
    if (normName.contains(cleanQuery)) return 1000;

    // 7. Exact match on province code (e.g. "RM")
    if (normState == cleanQuery) return 600;

    // 8. Substring containment in combined name + state
    if (normFull.contains(cleanQuery)) return 500;

    // 9. Fuzzy matching for typos (only enabled for queries of 4+ characters)
    if (cleanQuery.length >= 4) {
      final maxDistance = cleanQuery.length <= 6 ? 1 : 2;

      // Check whole name distance first if length is within bound
      if ((normName.length - cleanQuery.length).abs() <= maxDistance) {
        final dist = damerauLevenshteinDistance(normName, cleanQuery);
        if (dist <= maxDistance) {
          return dist == 1 ? 400 : 200;
        }
      }

      // Check individual words distance
      for (final word in words) {
        if ((word.length - cleanQuery.length).abs() <= maxDistance) {
          final dist = damerauLevenshteinDistance(word, cleanQuery);
          if (dist <= maxDistance) {
            return dist == 1 ? 350 : 150;
          }
        }
      }
    }

    return 0;
  }

  /// Filters and ranks [birthplaces] based on [query].
  /// Returns at most [limit] items, prioritized by match quality and name length.
  static List<Birthplace> search(
    List<Birthplace> birthplaces,
    String query, {
    int limit = 20,
  }) {
    final cleanQuery = normalize(query);
    if (cleanQuery.length < 2) return const [];

    final scored = <({Birthplace birthplace, int score, int length})>[];

    for (final b in birthplaces) {
      final normName = normalize(b.name);
      final normState = normalize(b.state);
      final normFull = '$normName $normState';
      final words = normName.split(' ');

      final score = computeScore(
        normName: normName,
        normState: normState,
        normFull: normFull,
        words: words,
        cleanQuery: cleanQuery,
      );

      if (score > 0) {
        scored.add((
          birthplace: b,
          score: score,
          length: normName.length,
        ));
      }
    }

    // Sort order:
    // 1. Score descending (relevance)
    // 2. Length ascending (shorter, more specific names win)
    // 3. Alphabetical on name for consistency
    scored.sort((a, b) {
      final scoreDiff = b.score.compareTo(a.score);
      if (scoreDiff != 0) return scoreDiff;

      final lenDiff = a.length.compareTo(b.length);
      if (lenDiff != 0) return lenDiff;

      final nameDiff = a.birthplace.name.compareTo(b.birthplace.name);
      if (nameDiff != 0) return nameDiff;

      return a.birthplace.state.compareTo(b.birthplace.state);
    });

    return scored.take(limit).map((e) => e.birthplace).toList();
  }
}
