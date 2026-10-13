// CLI tool for ARB localization file sorting, checking, and validation.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Exit codes following standard Unix conventions.
abstract final class ExitCodes {
  static const int success = 0;
  static const int error = 1;
}

void main(List<String> args) {
  final arbTool = ArbTool();
  final exitCode = arbTool.run(args);
  exit(exitCode);
}

/// Core processor and command runner for ARB localization files.
class ArbTool {
  static const JsonEncoder jsonEncoder = JsonEncoder.withIndent('  ');
  static final RegExp placeholderRegex = RegExp(
    r'\{([a-zA-Z0-9_]+)(?:,[^}]*)?\}',
  );

  /// Runs the tool with the provided command-line arguments.
  int run(List<String> args) {
    if (args.isEmpty ||
        args.contains('-h') ||
        args.contains('--help') ||
        args.first == 'help') {
      _printUsage();
      return ExitCodes.success;
    }

    final command = args.first.toLowerCase();
    final fileArgs = args.sublist(1);

    final files = _resolveFiles(fileArgs);
    if (files.isEmpty) {
      print('No .arb files found to process.');
      return ExitCodes.success;
    }

    return switch (command) {
      'sort' => executeSort(files),
      'check' => executeCheck(files),
      'validate' => executeValidate(files),
      _ => _handleUnknownCommand(command),
    };
  }

  void _printUsage() {
    print('''
ARB Localization Tool (arb_tool)
Usage: dart run tool/arb_tool.dart <command> [file-paths...]

Commands:
  sort      Sort and format .arb files alphabetically, keeping @@ keys on top
            and placing metadata (@key) right after each base key.
  check     Verify whether .arb files are sorted according to sort rules.
            Exits with code 1 if any file is unformatted or unsorted.
  validate  Perform strict semantic validation on .arb files:
            - Mandatory non-empty description for every base key (@key.description).
            - Mandatory type declaration for all placeholders.
            - 100% key parity between language files in the same directory.
            - No orphan metadata keys (@key without a matching base key).

Options:
  -h, --help  Show this help usage information.

If no file paths are provided, all .arb files in the workspace will be processed.
''');
  }

  int _handleUnknownCommand(String command) {
    print('Error: Unknown command "$command".');
    _printUsage();
    return ExitCodes.error;
  }

  /// Finds and resolves all target ARB files.
  List<File> _resolveFiles(List<String> explicitPaths) {
    if (explicitPaths.isNotEmpty) {
      return explicitPaths.map(File.new).where((f) => f.existsSync()).toList();
    }

    final List<File> arbFiles = <File>[];
    final Directory rootDir = Directory.current;

    void scan(Directory dir) {
      try {
        final entities = dir.listSync(followLinks: false);
        for (final entity in entities) {
          if (entity is Directory) {
            final name = entity.uri.pathSegments
                .where((s) => s.isNotEmpty)
                .last;
            if (!name.startsWith('.') && name != 'build') {
              scan(entity);
            }
          } else if (entity is File && entity.path.endsWith('.arb')) {
            arbFiles.add(entity);
          }
        }
      } on Object {
        // Skip inaccessible folders
      }
    }

    scan(rootDir);
    arbFiles.sort((a, b) => a.path.compareTo(b.path));
    return arbFiles;
  }

  /// Sorts ARB files in place.
  int executeSort(List<File> files) {
    print('Sorting ${files.length} .arb file(s)...');
    var successCount = 0;

    for (final file in files) {
      try {
        final content = file.readAsStringSync();
        final Map<String, dynamic> arbMap =
            json.decode(content) as Map<String, dynamic>;

        final sortedMap = sortArbMap(arbMap);
        final sortedContent = '${jsonEncoder.convert(sortedMap)}\n';

        file.writeAsStringSync(sortedContent);
        print('  ✓ Successfully sorted: ${file.path}');
        successCount++;
      } on Object catch (e) {
        print('  ✗ Failed to sort ${file.path}: $e');
      }
    }

    print('Sort completed: $successCount/${files.length} file(s) sorted.');
    return successCount == files.length ? ExitCodes.success : ExitCodes.error;
  }

  /// Checks whether ARB files are properly sorted.
  int executeCheck(List<File> files) {
    print(
      'Checking formatting and ordering of ${files.length} .arb file(s)...',
    );
    final unsortedFiles = <String>[];

    for (final file in files) {
      try {
        final content = file.readAsStringSync().replaceAll('\r\n', '\n');
        final Map<String, dynamic> arbMap =
            json.decode(content) as Map<String, dynamic>;

        final sortedMap = sortArbMap(arbMap);
        final expectedContent = '${jsonEncoder.convert(sortedMap)}\n';

        if (content != expectedContent) {
          unsortedFiles.add(file.path);
          print('  ✗ Unsorted: ${file.path}');
        } else {
          print('  ✓ Properly sorted: ${file.path}');
        }
      } on Object catch (e) {
        unsortedFiles.add(file.path);
        print('  ✗ Error reading ${file.path}: $e');
      }
    }

    if (unsortedFiles.isNotEmpty) {
      print(
        '\nCheck failed: ${unsortedFiles.length} file(s) are not properly sorted.',
      );
      print('Run `dart run tool/arb_tool.dart sort` to format them.');
      return ExitCodes.error;
    }

    print(
      '\nCheck passed: All ${files.length} .arb file(s) are properly sorted.',
    );
    return ExitCodes.success;
  }

  /// Strictly validates ARB completeness, metadata, placeholders, and language parity.
  int executeValidate(List<File> files) {
    print('Validating ${files.length} .arb file(s)...');
    final errors = <String>[];

    // 1. Validate per-file metadata, description, and placeholders
    final Map<String, Map<String, dynamic>> parsedFiles = {};

    for (final file in files) {
      try {
        final content = file.readAsStringSync();
        final map = json.decode(content) as Map<String, dynamic>;
        parsedFiles[file.path] = map;

        final baseKeys = map.keys.where((k) => !k.startsWith('@')).toSet();
        final metaKeys = map.keys
            .where((k) => k.startsWith('@') && !k.startsWith('@@'))
            .toSet();

        // 1.1 Check mandatory @key and @key.description
        for (final key in baseKeys) {
          final metaKey = '@$key';
          if (!map.containsKey(metaKey)) {
            errors.add(
              '${file.path}: Missing required metadata "$metaKey" for key "$key".',
            );
            continue;
          }

          final meta = map[metaKey];
          if (meta is! Map) {
            errors.add(
              '${file.path}: Metadata "$metaKey" must be a JSON object.',
            );
            continue;
          }

          final description = meta['description'];
          if (description == null || description.toString().trim().isEmpty) {
            errors.add('${file.path}: Missing or empty "@$key.description".');
          }

          // 1.2 Check placeholders & types
          final value = map[key];
          if (value is String) {
            final tokensInMessage = placeholderRegex
                .allMatches(value)
                .map((m) => m.group(1)!)
                .toSet();

            if (tokensInMessage.isNotEmpty) {
              final placeholdersObj = meta['placeholders'];
              if (placeholdersObj is! Map) {
                errors.add(
                  '${file.path}: Key "$key" contains placeholders $tokensInMessage but "$metaKey.placeholders" is missing or not an object.',
                );
              } else {
                for (final token in tokensInMessage) {
                  final phDef = placeholdersObj[token];
                  if (phDef is! Map) {
                    errors.add(
                      '${file.path}: Placeholder "{$token}" in key "$key" is not defined in "$metaKey.placeholders".',
                    );
                  } else {
                    final type = phDef['type'];
                    if (type == null || type.toString().trim().isEmpty) {
                      errors.add(
                        '${file.path}: Placeholder "{$token}" in key "$key" is missing mandatory "type" specification.',
                      );
                    }
                  }
                }
              }
            }
          }
        }

        // 1.3 Check for orphan metadata keys
        for (final metaKey in metaKeys) {
          final baseKey = metaKey.substring(1);
          if (!baseKeys.contains(baseKey)) {
            errors.add(
              '${file.path}: Orphan metadata "$metaKey" found without matching base key "$baseKey".',
            );
          }
        }
      } on Object catch (e) {
        errors.add('${file.path}: JSON parse error: $e');
      }
    }

    // 2. Check 100% language parity between files in the same directory
    final Map<String, List<String>> filesByDirectory = {};
    for (final path in parsedFiles.keys) {
      final dir = File(path).parent.path;
      filesByDirectory.putIfAbsent(dir, () => []).add(path);
    }

    for (final entry in filesByDirectory.entries) {
      final groupPaths = entry.value;
      if (groupPaths.length <= 1) continue;

      final Map<String, Set<String>> keysByFile = {};
      final Set<String> allKeys = {};

      for (final p in groupPaths) {
        final map = parsedFiles[p]!;
        final baseKeys = map.keys.where((k) => !k.startsWith('@')).toSet();
        keysByFile[p] = baseKeys;
        allKeys.addAll(baseKeys);
      }

      for (final p in groupPaths) {
        final currentKeys = keysByFile[p]!;
        final missingKeys = allKeys.difference(currentKeys);
        if (missingKeys.isNotEmpty) {
          final sortedMissing = missingKeys.toList()..sort();
          errors.add(
            '$p: Missing ${sortedMissing.length} key(s) present in other bundle files: ${sortedMissing.join(', ')}',
          );
        }
      }
    }

    if (errors.isNotEmpty) {
      print('\nValidation failed with ${errors.length} issue(s):');
      for (final err in errors) {
        print('  ✗ $err');
      }
      return ExitCodes.error;
    }

    print(
      '\nValidation passed: All ${files.length} .arb file(s) satisfy strict localization rules.',
    );
    return ExitCodes.success;
  }

  /// Sorts an ARB map deterministically:
  /// 1. Special `@@` keys alphabetically.
  /// 2. Base keys alphabetically, each followed immediately by its `@key` metadata.
  /// 3. Remaining metadata keys alphabetically.
  static Map<String, dynamic> sortArbMap(Map<String, dynamic> arbMap) {
    final Map<String, dynamic> result = <String, dynamic>{};

    // 1. Handle special keys starting with @@ (e.g. @@locale, @@author)
    final List<String> specialKeys =
        arbMap.keys.where((k) => k.startsWith('@@')).toList()..sort();
    for (final String key in specialKeys) {
      result[key] = arbMap[key];
    }

    // 2. Handle base keys (not starting with @)
    final List<String> baseKeys =
        arbMap.keys.where((k) => !k.startsWith('@')).toList()..sort();

    final Set<String> usedMetadataKeys = <String>{};

    for (final String key in baseKeys) {
      result[key] = arbMap[key];
      final String metadataKey = '@$key';
      if (arbMap.containsKey(metadataKey)) {
        result[metadataKey] = arbMap[metadataKey];
        usedMetadataKeys.add(metadataKey);
      }
    }

    // 3. Handle remaining metadata keys
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
}
