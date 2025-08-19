part of '../../card_parser_service.dart';

/// A simple container for birth information extracted from the card.
class _BirthInfoResult {
  final DateTime? birthDate;
  final String? birthPlaceName;
  final String? birthPlaceState;
  _BirthInfoResult({this.birthDate, this.birthPlaceName, this.birthPlaceState});
}

/// A simple container for a search result.
class _SearchResult {
  final String value;
  final int lineIndex;
  _SearchResult(this.value, this.lineIndex);
}

/// A mixin that provides helper methods for parsing card text.
/// It includes methods for pre-processing text, detecting card types,
/// finding values with fuzzy matching, and extracting birth information.
mixin _ParserHelpersMixin {
  List<String> _preProcessText(String rawText) {
    return rawText
        .toUpperCase()
        .split('\n')
        .map((l) => l.trim().replaceAll('/', ' '))
        .where((l) => l.isNotEmpty)
        .toList();
  }

  /// Detects the type of card based on the content of the lines.
  /// Returns CardType.cie for Carta d'Identità Elettronica,
  /// CardType.ts for Tessera Sanitaria,
  /// or CardType.unknown if it cannot be determined.
  CardType _detectCardType(List<String> lines) {
    final cieTarget = 'CARTA DI IDENTITA';
    final tsTarget = 'TESSERA SANITARIA';
    int bestCieScore = 999;
    int bestTsScore = 999;
    for (final line in lines) {
      if (line.contains('IDENTITA')) {
        for (int i = 0; i <= line.length - cieTarget.length; i++) {
          final sub = line.substring(i, i + cieTarget.length);
          bestCieScore = min(bestCieScore, _levenshtein(sub, cieTarget));
        }
      }
      if (line.contains('SANITARIA')) {
        for (int i = 0; i <= line.length - tsTarget.length; i++) {
          final sub = line.substring(i, i + tsTarget.length);
          bestTsScore = min(bestTsScore, _levenshtein(sub, tsTarget));
        }
      }
    }
    if (bestCieScore <= 3 && bestCieScore < bestTsScore) return CardType.cie;
    if (bestTsScore <= 3 && bestTsScore < bestCieScore) return CardType.ts;
    return CardType.unknown;
  }

  /// Finds the best matching line for a label and intelligently extracts the value,
  /// checking both on the same line and on the next line.
  String? _findValueFuzzy(
    List<String> lines,
    List<String> targetLabels, {
    int maxDistance = 2,
  }) {
    int bestDistance = 999;
    int? bestIndex;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(RegExp(r'[\s:]+'));
      if (parts.isEmpty) continue;

      final firstPart = parts.first;
      for (final label in targetLabels) {
        final distance = _levenshtein(firstPart, label);
        if (distance < bestDistance) {
          bestDistance = distance;
          bestIndex = i;
        }
      }
    }

    if (bestIndex != null && bestDistance <= maxDistance) {
      final labelLine = lines[bestIndex];
      final parts = labelLine.split(RegExp(r'[\s:]+'));

      if (parts.length > 1) return parts.sublist(1).join(' ');
      if (bestIndex + 1 < lines.length) return lines[bestIndex + 1];
      if (bestIndex > 0) return lines[bestIndex - 1];
    }

    return null;
  }

  /// Finds the best matching line by checking individual words, and returns the next line.
  /// Specific for CIE layout.
  _SearchResult? _findValueOnNextLineFuzzy(
    List<String> lines,
    List<String> targetLabels, {
    int maxDistance = 2,
    int lineOffset = 0,
  }) {
    int bestDistance = 999;
    int? bestIndex;

    for (int i = lineOffset; i < lines.length; i++) {
      final parts = lines[i].split(RegExp(r'[\s/:]+'));
      int lineMinDistance = 999;

      for (final part in parts) {
        for (final label in targetLabels) {
          final distance = _levenshtein(part, label);
          if (distance < lineMinDistance) {
            lineMinDistance = distance;
          }
        }
      }

      if (lineMinDistance < bestDistance) {
        bestDistance = lineMinDistance;
        bestIndex = i;
      }
    }

    if (bestIndex != null &&
        bestDistance <= maxDistance &&
        bestIndex + 1 < lines.length) {
      return _SearchResult(lines[bestIndex + 1], bestIndex + 1);
    }
    return null;
  }

  /// Specialized extractor for gender on CIE cards.
  String? _findGenderFuzzy(List<String> lines, {int maxDistance = 2}) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(RegExp(r'[\s/:]+'));
      bool isLabelMatch = false;

      for (final part in parts) {
        if (_levenshtein(part, 'SESSO') <= maxDistance ||
            _levenshtein(part, 'SEX') <= maxDistance) {
          isLabelMatch = true;
          break;
        }
      }

      if (isLabelMatch) {
        if (line.contains(' M')) return 'M';
        if (line.contains(' F')) return 'F';

        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (nextLine == 'M' || nextLine == 'F') return nextLine;
        }

        if (i + 2 < lines.length) {
          final twoLinesLater = lines[i + 2];
          if (twoLinesLater == 'M' || twoLinesLater == 'F') {
            return twoLinesLater;
          }
        }
      }
    }
    return null;
  }

  /// Extracts birth info using a regex, specific for the CIE structure.
  _BirthInfoResult? _extractBirthInfoCIE(List<String> lines) {
    final fullText = lines.join('\n');
    final birthPattern = RegExp(
      r"([A-ZÀ-Ú' ]+)\s*\(([A-Z]{2})\)\s*(\d{2}[./]\d{2}[./]\d{4})",
      caseSensitive: false,
      dotAll: true,
    );

    final match = birthPattern.firstMatch(fullText);
    if (match != null) {
      final dateString = match.group(3)?.replaceAll('.', '/');
      return _BirthInfoResult(
        birthPlaceName: match.group(1)?.trim(),
        birthPlaceState: match.group(2)?.trim(),
        birthDate: dateString != null
            ? DateFormat('dd/MM/yyyy').tryParse(dateString)
            : null,
      );
    }
    return null;
  }

  /// Extracts the birth date from TS text by finding all dates and picking the oldest one.
  DateTime? _findBirthDateTS(List<String> lines) {
    final datePattern = RegExp(r'(\d{2}/\d{2}/\d{4})');
    final allDates = datePattern
        .allMatches(lines.join('\n'))
        .map((m) => DateFormat('dd/MM/yyyy').tryParse(m.group(1)!))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();

    if (allDates.isNotEmpty) {
      allDates.sort((a, b) => a.compareTo(b));
      return allDates.first;
    }
    return null;
  }

  /// Calculates the Levenshtein distance between two strings.
  /// A measure of similarity: 0 is identical, higher numbers mean more different.
  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    var v0 = List<int>.generate(s2.length + 1, (i) => i);
    var v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < s2.length + 1; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }
}
