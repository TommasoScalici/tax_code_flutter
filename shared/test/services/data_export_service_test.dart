import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/data_export_service.dart';

void main() {
  late DataExportService service;

  setUp(() {
    service = const DataExportService();
  });

  final contact1 = Contact(
    id: 'id-1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: 'RSSMRA80A01H501U',
    birthPlace: const Birthplace(
      name: 'Roma',
      state: 'RM',
      code: 'H501',
    ),
    birthDate: DateTime(1980),
    listIndex: 0,
  );

  final contact2 = Contact(
    id: 'id-2',
    firstName: 'Luigi, Jr.',
    lastName: 'Verdi "The Chef"',
    gender: 'M',
    taxCode: 'VRDLGU85M15F205Z',
    birthPlace: const Birthplace(
      name: "Reggio nell'Emilia\nCentro",
      state: 'RE',
      code: 'H223',
    ),
    birthDate: DateTime(1985, 8, 15),
    listIndex: 1,
  );

  group('DataExportService Metadata', () {
    test('returns correct extensions', () {
      expect(service.fileExtension(ExportFormat.json), 'json');
      expect(service.fileExtension(ExportFormat.csv), 'csv');
    });

    test('returns correct MIME types', () {
      expect(service.mimeType(ExportFormat.json), 'application/json');
      expect(service.mimeType(ExportFormat.csv), 'text/csv');
    });
  });

  group('DataExportService JSON Export', () {
    test('formats empty contacts list to empty JSON array', () {
      final output = service.formatContacts(
        contacts: [],
        format: ExportFormat.json,
      );
      expect(output, '[]');
      expect(jsonDecode(output), isEmpty);
    });

    test('formats contacts to valid indented JSON with correct fields', () {
      final output = service.formatContacts(
        contacts: [contact1, contact2],
        format: ExportFormat.json,
      );

      final decoded = jsonDecode(output) as List<dynamic>;
      expect(decoded, hasLength(2));

      final first = decoded[0] as Map<String, dynamic>;
      expect(first['id'], 'id-1');
      expect(first['firstName'], 'Mario');
      expect(first['lastName'], 'Rossi');
      expect(first['gender'], 'M');
      expect(first['taxCode'], 'RSSMRA80A01H501U');
      final birthPlace = first['birthPlace'] as Map<String, dynamic>;
      expect(birthPlace['name'], 'Roma');
      expect(birthPlace['state'], 'RM');
      expect(birthPlace['code'], 'H501');

      final second = decoded[1] as Map<String, dynamic>;
      expect(second['id'], 'id-2');
      expect(second['firstName'], 'Luigi, Jr.');
      expect(second['lastName'], 'Verdi "The Chef"');
    });
  });

  group('DataExportService CSV Export', () {
    test('formats empty contacts list to CSV header only with CRLF', () {
      final output = service.formatContacts(
        contacts: [],
        format: ExportFormat.csv,
      );

      const expectedHeader =
          'ID,Nome,Cognome,Sesso,CodiceFiscale,DataDiNascita,Comune,Provincia,CodiceCatastale\r\n';
      expect(output, expectedHeader);
    });

    test('formats contacts and applies RFC 4180 escaping properly', () {
      final output = service.formatContacts(
        contacts: [contact1, contact2],
        format: ExportFormat.csv,
      );

      final lines = output.split('\r\n');
      // header + row 1 + row 2 (which spans 2 lines due to embedded \n) + trailing empty
      expect(lines[0], 'ID,Nome,Cognome,Sesso,CodiceFiscale,DataDiNascita,Comune,Provincia,CodiceCatastale');
      expect(
        lines[1],
        'id-1,Mario,Rossi,M,RSSMRA80A01H501U,1980-01-01,Roma,RM,H501',
      );

      // Verify contact2 row escaping:
      // "Luigi, Jr." -> contains comma -> escaped with quotes
      // "Verdi ""The Chef""" -> contains quotes -> quotes doubled and enclosed
      // "Reggio nell'Emilia\nCentro" -> contains newline -> enclosed in quotes
      expect(output, contains('"Luigi, Jr."'));
      expect(output, contains('"Verdi ""The Chef"""'));
      expect(output, contains('"Reggio nell\'Emilia\nCentro"'));
    });
  });
}
