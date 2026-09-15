import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared/models/contact.dart';

/// Supported export formats for offline backup.
enum ExportFormat {
  /// Structured JavaScript Object Notation (.json)
  json,

  /// Comma-Separated Values (.csv) compliant with RFC 4180
  csv,
}

/// Defines the contract for serializing contact lists into exportable formats.
abstract class DataExportServiceAbstract {
  /// Formats the list of [contacts] into a formatted string in the specified [format].
  String formatContacts({
    required List<Contact> contacts,
    required ExportFormat format,
  });

  /// Returns the file extension (without dot) for the given [format].
  String fileExtension(ExportFormat format);

  /// Returns the MIME type for the given [format].
  String mimeType(ExportFormat format);
}

/// Concrete implementation of [DataExportServiceAbstract] handling
/// formatted JSON and RFC 4180-compliant CSV generation.
class DataExportService implements DataExportServiceAbstract {
  /// Creates a [DataExportService].
  const DataExportService();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static const List<String> _csvHeaders = [
    'ID',
    'Nome',
    'Cognome',
    'Sesso',
    'CodiceFiscale',
    'DataDiNascita',
    'Comune',
    'Provincia',
    'CodiceCatastale',
  ];

  @override
  String formatContacts({
    required List<Contact> contacts,
    required ExportFormat format,
  }) {
    switch (format) {
      case ExportFormat.json:
        return _formatJson(contacts);
      case ExportFormat.csv:
        return _formatCsv(contacts);
    }
  }

  @override
  String fileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
    }
  }

  @override
  String mimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.csv:
        return 'text/csv';
    }
  }

  String _formatJson(List<Contact> contacts) {
    final jsonList = contacts
        .map(
          (c) => <String, dynamic>{
            'id': c.id,
            'firstName': c.firstName,
            'lastName': c.lastName,
            'gender': c.gender,
            'taxCode': c.taxCode,
            'birthPlace': c.birthPlace.toJson(),
            'birthDate': c.birthDate.toIso8601String(),
            'listIndex': c.listIndex,
          },
        )
        .toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  String _formatCsv(List<Contact> contacts) {
    final buffer = StringBuffer()
      ..write(_csvHeaders.map(_escapeCsvField).join(','))
      ..write('\r\n');

    for (final contact in contacts) {
      final row = [
        contact.id,
        contact.firstName,
        contact.lastName,
        contact.gender,
        contact.taxCode,
        _dateFormat.format(contact.birthDate),
        contact.birthPlace.name,
        contact.birthPlace.state,
        contact.birthPlace.code,
      ];
      buffer
        ..write(row.map(_escapeCsvField).join(','))
        ..write('\r\n');
    }

    return buffer.toString();
  }

  static String _escapeCsvField(String field) {
    final containsSpecialChars = field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r');

    if (!containsSpecialChars) {
      return field;
    }

    // RFC 4180: If double-quotes are used to enclose fields, then a double-quote
    // appearing inside a field must be escaped by preceding it with another double quote.
    final escaped = field.replaceAll('"', '""');
    return '"$escaped"';
  }
}
