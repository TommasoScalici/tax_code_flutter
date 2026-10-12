import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/widgets/share/contact_share_format.dart';

/// Encapsulates the output of a generated contact export file ready to be shared.
class ContactShareFileResult {
  /// The local file on disk containing the rendered asset.
  final File file;

  /// The standard MIME type of the generated file (e.g. image/png, application/pdf).
  final String mimeType;

  /// The localized email / share sheet subject line.
  final String subject;

  /// Creates a [ContactShareFileResult].
  const ContactShareFileResult({
    required this.file,
    required this.mimeType,
    required this.subject,
  });
}

/// Helper service responsible for generating temporary cached files (PNG / PDF)
/// for sharing contact details.
abstract final class ContactShareFileHelper {
  /// Prepares a temporary image or PDF file on disk for the specified [contact] and [format].
  static Future<ContactShareFileResult> prepareExportFile({
    required Contact contact,
    required ContactShareFormat format,
    required ContactCardImageService imageService,
    required ContactPdfService pdfService,
    required AppLocalizations l10n,
    Future<Directory> Function() getTempDir = getTemporaryDirectory,
  }) async {
    final tempDir = await getTempDir();
    final sanitizedCode = contact.taxCode.isNotEmpty
        ? contact.taxCode
        : 'codice_fiscale';

    final contactName =
        '${contact.firstName} ${contact.lastName}'.trim().isNotEmpty
            ? '${contact.firstName} ${contact.lastName}'.trim()
            : contact.taxCode;

    if (format == ContactShareFormat.image) {
      final bytes = await imageService.generateCardImage(
        contact: contact,
        l10n: l10n,
      );
      final fileName = 'tessera_$sanitizedCode.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return ContactShareFileResult(
        file: file,
        mimeType: 'image/png',
        subject: l10n.shareCardSubject(contactName),
      );
    } else if (format == ContactShareFormat.pdf) {
      final bytes = await pdfService.generateContactPdf(
        contact: contact,
        l10n: l10n,
      );
      final fileName = 'scheda_$sanitizedCode.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return ContactShareFileResult(
        file: file,
        mimeType: 'application/pdf',
        subject: l10n.sharePdfSubject(contactName),
      );
    }

    throw ArgumentError('Format $format does not generate a file export.');
  }
}
