import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/data_export_service.dart';

/// Encapsulates the output of a generated contacts export file ready to be shared.
class ExportDataFileResult {
  /// The local file on disk containing the rendered export content.
  final File file;

  /// The timestamped file name (e.g. `codici_fiscali_20261012_143000.json`).
  final String fileName;

  /// The standard MIME type for the exported format.
  final String mimeType;

  /// Creates an [ExportDataFileResult].
  const ExportDataFileResult({
    required this.file,
    required this.fileName,
    required this.mimeType,
  });
}

/// Helper service responsible for generating temporary cached files (JSON / CSV)
/// from a collection of contacts.
abstract final class ExportDataFileHelper {
  /// Formats [contacts] into the chosen [format] and writes the content to a temporary file.
  static Future<ExportDataFileResult> prepareExportFile({
    required List<Contact> contacts,
    required ExportFormat format,
    required DataExportServiceAbstract exportService,
    Future<Directory> Function() getTempDir = getTemporaryDirectory,
    DateTime? now,
  }) async {
    final dataString = exportService.formatContacts(
      contacts: contacts,
      format: format,
    );

    final ext = exportService.fileExtension(format);
    final mimeType = exportService.mimeType(format);

    final currentTimestamp = now ?? DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(currentTimestamp);
    final fileName = 'codici_fiscali_$timestamp.$ext';

    final tempDir = await getTempDir();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(dataString);

    return ExportDataFileResult(
      file: file,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
