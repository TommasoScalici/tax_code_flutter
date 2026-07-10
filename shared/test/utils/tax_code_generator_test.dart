import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/tax_code_generator.dart';

void main() {
  group('TaxCodeGenerator', () {
    test('should calculate correct tax code for standard Italian male', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Mario',
        lastName: 'Rossi',
        dateOfBirth: DateTime(1980, 1, 5),
        gender: 'M',
        birthplaceCode: 'H501', // Roma
      );
      expect(code, 'RSSMRA80A05H501H');
    });

    test('should calculate correct tax code for standard Italian female', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Maria',
        lastName: 'Rossi',
        dateOfBirth: DateTime(1980, 1, 5),
        gender: 'F',
        birthplaceCode: 'H501', // Roma
      );
      expect(code, 'RSSMRA80A45H501L');
    });

    test('should calculate correct tax code with name consolidation rules (4+ consonants)', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Tommaso', // T, M, M, S (consonants: T,M,M,S -> 1st,3rd,4th -> T,M,S)
        lastName: 'Scalici', // S, C, L, C -> 1st 3 -> S,C,L
        dateOfBirth: DateTime(1995, 7, 24),
        gender: 'M',
        birthplaceCode: 'F205', // Milano
      );
      expect(code, 'SCLTMS95L24F205H');
    });

    test('should calculate correct tax code for foreign births', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Jean',
        lastName: 'Dupont',
        dateOfBirth: DateTime(1990, 5, 12),
        gender: 'M',
        birthplaceCode: 'Z110', // Francia
      );
      expect(code, 'DPNJNE90E12Z110I');
    });

    test('should handle short names by padding with X', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Li',
        lastName: 'Fo',
        dateOfBirth: DateTime(2000, 12, 1),
        gender: 'M',
        birthplaceCode: 'Z210', // Cina
      );
      expect(code, 'FOXLIX00T01Z210W');
    });

    test('should handle accented characters by normalizing them', () {
      final code = TaxCodeGenerator.generate(
        firstName: 'Niccolò',
        lastName: 'Sarrià',
        dateOfBirth: DateTime(1985, 9, 15),
        gender: 'M',
        birthplaceCode: 'H501',
      );
      expect(code, 'SRRNCL85P15H501X');
    });
  });
}
