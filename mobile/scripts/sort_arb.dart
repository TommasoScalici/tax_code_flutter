// ARB files are scripts and printing to console is the intended way
// to provide feedback to the user.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart scripts/sort_arb.dart <path_to_arb_file>');
    exit(1);
  }

  final String filePath = args[0];
  final File file = File(filePath);

  if (!file.existsSync()) {
    print('Error: File not found at $filePath');
    exit(1);
  }

  try {
    final String content = file.readAsStringSync();
    final Map<String, dynamic> arbMap =
        json.decode(content) as Map<String, dynamic>;

    final Map<String, dynamic> sortedMap = sortArbMap(arbMap);

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String sortedContent = encoder.convert(sortedMap);

    file.writeAsStringSync('$sortedContent\n');
    print('Successfully sorted $filePath');
  } on Exception catch (e) {
    print('Error processing ARB file: $e');
    exit(1);
  }
}

Map<String, dynamic> sortArbMap(Map<String, dynamic> arbMap) {
  final Map<String, dynamic> result = <String, dynamic>{};

  // 1. Handle special keys starting with @@ (e.g., @@locale)
  final List<String> specialKeys =
      arbMap.keys.where((k) => k.startsWith('@@')).toList()..sort();
  for (final String key in specialKeys) {
    result[key] = arbMap[key];
  }

  // 2. Handle base keys (not starting with @)
  final List<String> baseKeys =
      arbMap.keys.where((k) => !k.startsWith('@')).toList()..sort();

  // 3. Keep track of which metadata keys we've used
  final Set<String> usedMetadataKeys = <String>{};

  for (final String key in baseKeys) {
    result[key] = arbMap[key];
    final String metadataKey = '@$key';
    if (arbMap.containsKey(metadataKey)) {
      result[metadataKey] = arbMap[metadataKey];
      usedMetadataKeys.add(metadataKey);
    }
  }

  // 4. Handle any remaining metadata keys that don't have a corresponding
  // base key (excluding the @@ special keys already handled)
  final List<String> remainingMetadataKeys =
      arbMap.keys
          .where(
            (k) =>
                k.startsWith('@') &&
                !k.startsWith('@@') &&
                !usedMetadataKeys.contains(k),
          )
          .toList()
        ..sort();

  for (final String key in remainingMetadataKeys) {
    result[key] = arbMap[key];
  }

  return result;
}
