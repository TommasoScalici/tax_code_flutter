import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';

void main() {
  late ContactPdfService pdfService;

  final testContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1985, 4, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA85D15H501Z',
    listIndex: 0,
  );

  setUp(() {
    pdfService = const ContactPdfService();
  });

  group('ContactPdfService', () {
    test('generates non-empty PDF byte array with valid PDF header', () async {
      final pdfBytes = await pdfService.generateContactPdf(contact: testContact);

      expect(pdfBytes, isNotEmpty);
      // Valid PDF documents begin with the '%PDF-' magic header bytes (0x25, 0x50, 0x44, 0x46, 0x2D)
      expect(pdfBytes.length, greaterThan(100));
      expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
    });

    test('handles contact with empty birthplace code gracefully', () async {
      final contactWithoutCode = testContact.copyWith(
        birthPlace: const Birthplace(name: 'Comune Test', state: ''),
      );

      final pdfBytes = await pdfService.generateContactPdf(
        contact: contactWithoutCode,
      );

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
    });

    test('generates localized PDF with AppLocalizationsIt', () async {
      final pdfBytes = await pdfService.generateContactPdf(
        contact: testContact,
        l10n: AppLocalizationsIt(),
      );

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
    });
  });
}
