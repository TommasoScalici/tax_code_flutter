import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';

void main() {
  group('ScannedData', () {
    group('.fromJson factory', () {
      test('should create a valid ScannedData object from full JSON', () {
        // Arrange
        final json = {
          'firstName': 'Mario',
          'lastName': 'Rossi',
          'gender': 'M',
          'birthDate': '1980-01-15T00:00:00.000',
          'birthPlace': {'name': 'ROMA', 'state': 'RM'},
        };
        final expectedBirthDate = DateTime(1980, 1, 15);
        const expectedBirthPlace = Birthplace(name: 'ROMA', state: 'RM');

        // Act
        final scannedData = ScannedData.fromJson(json);

        // Assert
        expect(scannedData.firstName, 'Mario');
        expect(scannedData.lastName, 'Rossi');
        expect(scannedData.gender, 'M');
        expect(scannedData.birthDate, expectedBirthDate);
        expect(scannedData.birthPlace, expectedBirthPlace);
      });

      test(
        'should create an object with all null properties from empty JSON',
        () {
          // Arrange
          final json = <String, dynamic>{};

          // Act
          final scannedData = ScannedData.fromJson(json);

          // Assert
          expect(scannedData.firstName, isNull);
          expect(scannedData.lastName, isNull);
          expect(scannedData.gender, isNull);
          expect(scannedData.birthDate, isNull);
          expect(scannedData.birthPlace, isNull);
        },
      );

      test('should handle partially missing data correctly', () {
        // Arrange
        final json = {'firstName': 'Guido', 'gender': null};

        // Act
        final scannedData = ScannedData.fromJson(json);

        // Assert
        expect(scannedData.firstName, 'Guido');
        expect(scannedData.lastName, isNull);
        expect(scannedData.gender, isNull);
        expect(scannedData.birthDate, isNull);
        expect(scannedData.birthPlace, isNull);
      });

      test('should set birthDate to null if date string is malformed', () {
        // Arrange
        final json = {'birthDate': 'not-a-valid-date'};

        // Act
        final scannedData = ScannedData.fromJson(json);

        // Assert
        expect(scannedData.birthDate, isNull);
      });

      test('should set birthPlace to null if JSON value is not a map', () {
        // Arrange
        final json = {'birthPlace': 'not-a-map'};

        // Act
        final scannedData = ScannedData.fromJson(json);

        // Assert
        expect(scannedData.birthPlace, isNull);
      });
    });
  });
}
