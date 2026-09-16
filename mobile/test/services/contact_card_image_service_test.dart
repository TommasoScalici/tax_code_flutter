import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContactCardImageService imageService;

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
    imageService = const ContactCardImageService();
  });

  group('ContactCardImageService', () {
    test('generates non-empty PNG image bytes with valid PNG magic header', () async {
      final imageBytes = await imageService.generateCardImage(contact: testContact);

      expect(imageBytes, isNotEmpty);
      expect(imageBytes.length, greaterThan(1000));
      // PNG Magic Header: 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A
      expect(imageBytes[0], 0x89);
      expect(imageBytes[1], 0x50); // 'P'
      expect(imageBytes[2], 0x4E); // 'N'
      expect(imageBytes[3], 0x47); // 'G'
    });

    test('handles empty or special fields gracefully', () async {
      final customContact = testContact.copyWith(
        firstName: 'Anna Maria',
        lastName: "D'Amico",
        birthPlace: const Birthplace(name: 'Napoli', state: 'NA', code: 'F839'),
      );

      final imageBytes = await imageService.generateCardImage(contact: customContact);

      expect(imageBytes, isNotEmpty);
      expect(imageBytes[0], 0x89);
      expect(imageBytes[1], 0x50);
    });

    test('generates localized card image with AppLocalizationsIt', () async {
      final imageBytes = await imageService.generateCardImage(
        contact: testContact,
        l10n: AppLocalizationsIt(),
      );

      expect(imageBytes, isNotEmpty);
      expect(imageBytes[0], 0x89);
      expect(imageBytes[1], 0x50);
    });
  });
}
