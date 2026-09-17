import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// Contract for generating a printable PDF document of a [Contact]'s tax code data.
abstract class ContactPdfServiceAbstract {
  /// Generates the raw PDF bytes for a single [contact].
  Future<Uint8List> generateContactPdf({
    required Contact contact,
    AppLocalizations? l10n,
  });
}

/// Concrete implementation of [ContactPdfServiceAbstract] producing
/// clean, formatted A4 documents with 1D Barcode and 2D QR Code.
class ContactPdfService implements ContactPdfServiceAbstract {
  /// Creates a [ContactPdfService].
  const ContactPdfService();

  static final DateFormat _birthDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _generationDateFormat =
      DateFormat('dd/MM/yyyy HH:mm');

  @override
  Future<Uint8List> generateContactPdf({
    required Contact contact,
    AppLocalizations? l10n,
  }) async {
    final effectiveL10n = l10n ?? AppLocalizationsEn();
    final pdf = pw.Document();

    final emeraldColor = PdfColor.fromHex('#2E7D4E');
    final darkTextColor = PdfColor.fromHex('#1E1E1E');
    final greyTextColor = PdfColor.fromHex('#666666');
    final surfaceColor = PdfColor.fromHex('#F7F9F8');
    final borderColor = PdfColor.fromHex('#D8DFDB');

    final birthDateStr = _birthDateFormat.format(contact.birthDate);
    final birthplaceStr = contact.birthPlace.state.isNotEmpty
        ? '${contact.birthPlace.name} (${contact.birthPlace.state})'
        : contact.birthPlace.name;
    final belfioreStr = contact.birthPlace.code.isNotEmpty
        ? contact.birthPlace.code
        : '-';

    final generatedOn = _generationDateFormat.format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: pw.BoxDecoration(
                  color: emeraldColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          effectiveL10n.appName.toUpperCase(),
                          style: const pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          effectiveL10n.pdfSummarySubtitle,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius:
                            pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        effectiveL10n.pdfPersonalUseBadge,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: emeraldColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Tax code highlight card
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: surfaceColor,
                  border: pw.Border.all(color: borderColor, width: 1.2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      effectiveL10n.appName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: greyTextColor,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      contact.taxCode,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: emeraldColor,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Personal data table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: pw.BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const pw.BorderRadius.vertical(
                          top: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Text(
                        effectiveL10n.pdfPersonalDataHeader,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: darkTextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    _buildTableRow(effectiveL10n.lastName, contact.lastName, darkTextColor,
                        isFirst: true),
                    _buildTableRow(
                        effectiveL10n.firstName, contact.firstName, darkTextColor),
                    _buildTableRow(effectiveL10n.gender, contact.gender, darkTextColor),
                    _buildTableRow(
                        effectiveL10n.birthDate, birthDateStr, darkTextColor),
                    _buildTableRow(
                        effectiveL10n.birthPlace, birthplaceStr, darkTextColor),
                    _buildTableRow(
                      effectiveL10n.pdfCadastralCodeLabel,
                      belfioreStr,
                      darkTextColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Optical Codes (1D Barcode & 2D QR Code)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      effectiveL10n.pdfOpticalCodesHeader,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: darkTextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 14),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // 1D Barcode (Code 128)
                        pw.Expanded(
                          child: pw.Column(
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.code128(),
                                data: contact.taxCode,
                                width: 280,
                                height: 55,
                                drawText: false,
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                effectiveL10n.barcodeCode128,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: greyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        // 2D QR Code
                        pw.Column(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: contact.taxCode,
                              width: 65,
                              height: 65,
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              effectiveL10n.cardQrCodeLabel,
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: greyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    effectiveL10n.pdfGeneratedOnFooter(generatedOn),
                    style: pw.TextStyle(fontSize: 8, color: greyTextColor),
                  ),
                  pw.Text(
                    effectiveL10n.pdfUnofficialDisclaimer,
                    style: pw.TextStyle(fontSize: 8, color: greyTextColor),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildTableRow(
    String label,
    String value,
    PdfColor textColor, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: pw.BoxDecoration(
        border: isLast
            ? null
            : const pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey200),
              ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 170,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isNotEmpty ? value : '-',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
