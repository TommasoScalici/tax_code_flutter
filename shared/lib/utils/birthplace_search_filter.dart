import 'dart:typed_data';

import 'package:shared/models/birthplace.dart';

/// Utility class for performing smart, relevance-ranked searches over a list of [Birthplace]s.
abstract final class BirthplaceSearchFilter {
  // Pre-compiled regular expressions to prevent repeated allocation/compilation overhead
  static final RegExp _regexA = RegExp('[àáâãäå]');
  static final RegExp _regexE = RegExp('[èéêë]');
  static final RegExp _regexI = RegExp('[ìíîï]');
  static final RegExp _regexO = RegExp('[òóôõö]');
  static final RegExp _regexU = RegExp('[ùúûü]');
  static final RegExp _regexPunctuation = RegExp(r"['’\-\/\\,()]");
  static final RegExp _regexWhitespace = RegExp(r'\s+');

  /// Normalizes input string by converting to lower case, stripping diacritics/accents,
  /// replacing punctuation with spaces, and trimming duplicate whitespace.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(_regexA, 'a')
        .replaceAll(_regexE, 'e')
        .replaceAll(_regexI, 'i')
        .replaceAll(_regexO, 'o')
        .replaceAll(_regexU, 'u')
        .replaceAll(_regexPunctuation, ' ')
        .replaceAll(_regexWhitespace, ' ')
        .trim();
  }

  /// Calculates the Damerau-Levenshtein distance between [s1] and [s2].
  /// Supports insertions, deletions, substitutions, and adjacent transpositions.
  ///
  /// If [maxDistance] is specified, performs fast-fail early exit when
  /// length difference exceeds [maxDistance] or when the minimum cost in a row exceeds [maxDistance].
  /// In that case, returns [maxDistance] + 1.
  static int damerauLevenshteinDistance(
    String s1,
    String s2, [
    int? maxDistance,
  ]) {
    if (identical(s1, s2) || s1 == s2) return 0;

    var len1 = s1.length;
    var len2 = s2.length;

    if (maxDistance != null && (len1 - len2).abs() > maxDistance) {
      return maxDistance + 1;
    }

    if (len1 == 0) {
      return (maxDistance != null && len2 > maxDistance) ? maxDistance + 1 : len2;
    }
    if (len2 == 0) {
      return (maxDistance != null && len1 > maxDistance) ? maxDistance + 1 : len1;
    }

    // Orient strings so s2 is the shorter string, minimizing row buffer size.
    var str1 = s1;
    var str2 = s2;
    if (len1 < len2) {
      str1 = s2;
      str2 = s1;
      final tempLen = len1;
      len1 = len2;
      len2 = tempLen;
    }

    // Use 3 contiguous 1D Int32List buffers instead of a full 2D (len1+1)*(len2+1) matrix.
    // rowMinus2: values for row i - 2 (needed for adjacent transpositions)
    // rowMinus1: values for row i - 1
    // currentRow: values for row i
    var rowMinus2 = Int32List(len2 + 1);
    var rowMinus1 = Int32List(len2 + 1);
    var currentRow = Int32List(len2 + 1);

    for (var j = 0; j <= len2; j++) {
      rowMinus1[j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      currentRow[0] = i;
      var minInRow = i;
      final code1 = str1.codeUnitAt(i - 1);
      final prevCode1 = i > 1 ? str1.codeUnitAt(i - 2) : -1;

      for (var j = 1; j <= len2; j++) {
        final code2 = str2.codeUnitAt(j - 1);
        final cost = (code1 == code2) ? 0 : 1;

        var minVal = rowMinus1[j] + 1; // deletion
        final insertion = currentRow[j - 1] + 1;
        if (insertion < minVal) minVal = insertion;
        final substitution = rowMinus1[j - 1] + cost;
        if (substitution < minVal) minVal = substitution;

        // Transposition
        if (i > 1 &&
            j > 1 &&
            code1 == str2.codeUnitAt(j - 2) &&
            prevCode1 == code2) {
          final transposition = rowMinus2[j - 2] + cost;
          if (transposition < minVal) minVal = transposition;
        }

        currentRow[j] = minVal;
        if (minVal < minInRow) minInRow = minVal;
      }

      // Fast-fail early exit: if the minimum distance in this row already exceeds maxDistance,
      // subsequent rows can never drop below maxDistance.
      if (maxDistance != null && minInRow > maxDistance) {
        return maxDistance + 1;
      }

      // Rotate buffer pointers without any reallocations
      final temp = rowMinus2;
      rowMinus2 = rowMinus1;
      rowMinus1 = currentRow;
      currentRow = temp;
    }

    final finalDistance = rowMinus1[len2];
    if (maxDistance != null && finalDistance > maxDistance) {
      return maxDistance + 1;
    }
    return finalDistance;
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
        final dist = damerauLevenshteinDistance(
          normName,
          cleanQuery,
          maxDistance,
        );
        if (dist <= maxDistance) {
          return dist == 1 ? 400 : 200;
        }
      }

      // Check individual words distance
      for (final word in words) {
        if ((word.length - cleanQuery.length).abs() <= maxDistance) {
          final dist = damerauLevenshteinDistance(
            word,
            cleanQuery,
            maxDistance,
          );
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
      final score = computeScore(
        normName: b.normalizedName,
        normState: b.normalizedState,
        normFull: b.normalizedFull,
        words: b.nameWords,
        cleanQuery: cleanQuery,
      );

      if (score > 0) {
        scored.add((
          birthplace: b,
          score: score,
          length: b.normalizedName.length,
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
