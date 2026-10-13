import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/arb_tool.dart';

void main() {
  group('ArbTool', () {
    late ArbTool arbTool;
    late Directory tempDir;

    setUp(() {
      arbTool = ArbTool();
      tempDir = Directory.systemTemp.createTempSync('arb_tool_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    File createArbFile(String relativePath, Map<String, dynamic> data) {
      final file = File('${tempDir.path}/$relativePath');
      file.parent.createSync(recursive: true);
      const encoder = JsonEncoder.withIndent('  ');
      file.writeAsStringSync('${encoder.convert(data)}\n');
      return file;
    }

    group('sortArbMap', () {
      test('orders @@ keys first, then base keys with their metadata', () {
        final input = {
          'zebra': 'Zebra',
          '@zebra': {'description': 'A zebra.'},
          'apple': 'Apple',
          '@@locale': 'en',
          '@apple': {'description': 'An apple.'},
          '@@author': 'Author',
        };

        final sorted = ArbTool.sortArbMap(input);
        final keys = sorted.keys.toList();

        expect(keys, [
          '@@author',
          '@@locale',
          'apple',
          '@apple',
          'zebra',
          '@zebra',
        ]);
      });

      test('appends orphan metadata keys at the end', () {
        final input = {
          '@orphanKey': {'description': 'Orphan'},
          'banana': 'Banana',
          '@banana': {'description': 'A banana.'},
        };

        final sorted = ArbTool.sortArbMap(input);
        final keys = sorted.keys.toList();

        expect(keys, ['banana', '@banana', '@orphanKey']);
      });
    });

    group('executeCheck', () {
      test('returns success when files are correctly sorted', () {
        final file = createArbFile('app_en.arb', {
          '@@locale': 'en',
          'cancel': 'Cancel',
          '@cancel': {'description': 'Cancel button label.'},
        });

        final code = arbTool.executeCheck([file]);
        expect(code, ExitCodes.success);
      });

      test('returns error when file keys are out of order', () {
        final file = File('${tempDir.path}/unsorted.arb');
        file.writeAsStringSync(
          '{\n  "zebra": "Zebra",\n  "apple": "Apple"\n}\n',
        );

        final code = arbTool.executeCheck([file]);
        expect(code, ExitCodes.error);
      });
    });

    group('executeSort', () {
      test('sorts file in place and matches expected structure', () {
        final file = File('${tempDir.path}/to_sort.arb');
        file.writeAsStringSync(
          '{\n  "zebra": "Zebra",\n  "apple": "Apple"\n}\n',
        );

        final code = arbTool.executeSort([file]);
        expect(code, ExitCodes.success);

        final checkCode = arbTool.executeCheck([file]);
        expect(checkCode, ExitCodes.success);
      });
    });

    group('executeValidate', () {
      test(
        'passes on valid files with matching keys, descriptions, and placeholder types',
        () {
          final enFile = createArbFile('l10n/app_en.arb', {
            '@@locale': 'en',
            'welcome': 'Welcome, {name}!',
            '@welcome': {
              'description': 'Welcome greeting with user name.',
              'placeholders': {
                'name': {'type': 'String', 'example': 'Mario'},
              },
            },
          });

          final itFile = createArbFile('l10n/app_it.arb', {
            '@@locale': 'it',
            'welcome': 'Benvenuto, {name}!',
            '@welcome': {
              'description': 'Messaggio di benvenuto con nome utente.',
              'placeholders': {
                'name': {'type': 'String', 'example': 'Mario'},
              },
            },
          });

          final code = arbTool.executeValidate([enFile, itFile]);
          expect(code, ExitCodes.success);
        },
      );

      test('fails when @key metadata is missing', () {
        final file = createArbFile('app_en.arb', {'save': 'Save'});

        final code = arbTool.executeValidate([file]);
        expect(code, ExitCodes.error);
      });

      test('fails when @key.description is empty or missing', () {
        final file = createArbFile('app_en.arb', {
          'save': 'Save',
          '@save': {'description': '   '},
        });

        final code = arbTool.executeValidate([file]);
        expect(code, ExitCodes.error);
      });

      test('fails when placeholder has no type declared', () {
        final file = createArbFile('app_en.arb', {
          'itemCount': 'Items: {count}',
          '@itemCount': {
            'description': 'Item count display.',
            'placeholders': {
              'count': {'example': '5'},
            },
          },
        });

        final code = arbTool.executeValidate([file]);
        expect(code, ExitCodes.error);
      });

      test('fails when placeholder is missing from placeholders map', () {
        final file = createArbFile('app_en.arb', {
          'itemCount': 'Items: {count}',
          '@itemCount': {'description': 'Item count display.'},
        });

        final code = arbTool.executeValidate([file]);
        expect(code, ExitCodes.error);
      });

      test('fails when orphan metadata is present', () {
        final file = createArbFile('app_en.arb', {
          '@orphanKey': {'description': 'No base key.'},
        });

        final code = arbTool.executeValidate([file]);
        expect(code, ExitCodes.error);
      });

      test('fails when language parity is violated between bundle files', () {
        final enFile = createArbFile('bundle/app_en.arb', {
          '@@locale': 'en',
          'onlyEn': 'Only in English',
          '@onlyEn': {'description': 'Only English key.'},
        });

        final itFile = createArbFile('bundle/app_it.arb', {
          '@@locale': 'it',
          'onlyIt': 'Solo in Italiano',
          '@onlyIt': {'description': 'Chiave solo italiana.'},
        });

        final code = arbTool.executeValidate([enFile, itFile]);
        expect(code, ExitCodes.error);
      });
    });

    group('CLI run arguments', () {
      test('prints usage and returns 0 for --help', () {
        final code = arbTool.run(['--help']);
        expect(code, ExitCodes.success);
      });

      test('returns error for unknown command', () {
        final code = arbTool.run(['unknown_cmd']);
        expect(code, ExitCodes.error);
      });
    });
  });
}
