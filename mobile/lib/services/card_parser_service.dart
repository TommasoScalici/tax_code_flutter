import 'package:change_case/change_case.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:uuid/uuid.dart';

/// Defines the contract for a service that parses raw text from a card
/// into a structured Contact object.
abstract class CardParserServiceAbstract {
  Contact? parseText(String rawText);
}

/// The concrete implementation for parsing text from Italian identity cards
/// (Tessera Sanitaria, CIE) using Regular Expressions.
class CardParserService implements CardParserServiceAbstract {
  static final _lastNamePattern = RegExp(r"(?:Cognome|COGNOME/SURNAME)\s*[:\n]\s*([A-ZÀ-Ú'\s]+)");
  static final _firstNamePattern = RegExp(r"(?:Nome|NOME/NAME)\s*[:\n]\s*([A-ZÀ-Ú'\s]+)");
  static final _genderPattern = RegExp(r'(?:Sesso|SEX)\s*[:\s]*([MF])');
  static final _birthDatePattern = RegExp(r'Data\s*di\s*nascita\s*[:\s]*(\d{2}[./]\d{2}[./]\d{4})');
  static final _birthPlacePattern = RegExp(r"Luogo\s*di\s*nascita\s*[:\n]\s*([A-ZÀ-Ú'\s]+)");
  static final _provincePattern = RegExp(r'\(([A-Z]{2})\)');
  static final _cieBirthPattern = RegExp(r"([A-ZÀ-Ú'\s]+)\s+\(([A-Z]{2})\)\s+(\d{2}\.\d{2}\.\d{4})");

  @override
  Contact? parseText(String rawText) {
    String? firstName = _extractWithRegex(rawText, _firstNamePattern);
    String? lastName = _extractWithRegex(rawText, _lastNamePattern);
    String? gender = _extractWithRegex(rawText, _genderPattern);
    String? birthPlaceName;
    String? birthPlaceState;
    DateTime? birthDate;

    final cieMatch = _cieBirthPattern.firstMatch(rawText);
    if (cieMatch != null) {
      birthPlaceName = cieMatch.group(1)?.trim();
      birthPlaceState = cieMatch.group(2)?.trim();
      final dateString = cieMatch.group(3)?.replaceAll('.', '/');
      if (dateString != null) {
        birthDate = DateFormat('dd/MM/yyyy').tryParse(dateString);
      }
    } else {
      birthPlaceName = _extractWithRegex(rawText, _birthPlacePattern);
      birthPlaceState = _extractWithRegex(rawText, _provincePattern);
      final birthDateString = _extractWithRegex(rawText, _birthDatePattern);
      if (birthDateString != null) {
        birthDate = DateFormat('dd/MM/yyyy').tryParse(birthDateString.replaceAll('.', '/'));
      }
    }

    if (firstName != null &&
        lastName != null &&
        gender != null &&
        birthDate != null &&
        birthPlaceName != null &&
        birthPlaceState != null) {
      return Contact(
          id: const Uuid().v4(),
          firstName: firstName.toCapitalCase(),
          lastName: lastName.toCapitalCase(),
          gender: gender,
          taxCode: '',
          birthPlace: Birthplace(
            name: birthPlaceName.toCapitalCase(),
            state: birthPlaceState.toUpperCase(),
          ),
          birthDate: birthDate,
          listIndex: 0);
    }
    
    return null;
  }

  String? _extractWithRegex(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }
}