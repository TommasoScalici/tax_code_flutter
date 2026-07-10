class TaxCodeGenerator {
  /// Generates the 16-character Italian tax code (Codice Fiscale).
  static String generate({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required String birthplaceCode,
  }) {
    final cleanGender = gender.trim().toUpperCase();
    if (cleanGender != 'M' && cleanGender != 'F') {
      throw ArgumentError('Gender must be M or F');
    }

    final cleanBp = birthplaceCode.trim().toUpperCase();
    if (cleanBp.length != 4) {
      throw ArgumentError('Birthplace code must be 4 characters');
    }

    final lastNameCode = _getSurnameCode(lastName);
    final firstNameCode = _getFirstNameCode(firstName);
    final dobCode = _getDateAndGenderCode(dateOfBirth, cleanGender);

    final partial = '$lastNameCode$firstNameCode$dobCode$cleanBp';
    final checkChar = _getCheckCharacter(partial);

    return '$partial$checkChar';
  }

  static String _normalize(String input) {
    String s = input.trim().toUpperCase();

    // Character normalization for accented letters
    final accents = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'Æ': 'AE',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ø': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
      'Ñ': 'N',
    };
    accents.forEach((key, value) {
      s = s.replaceAll(key, value);
    });

    // Strip out all non-alphabetic characters
    return s.replaceAll(RegExp('[^A-Z]'), '');
  }

  static String _getSurnameCode(String surname) {
    final norm = _normalize(surname);
    final consonants = norm.replaceAll(RegExp('[AEIOU]'), '');
    final vowels = norm.replaceAll(RegExp('[^AEIOU]'), '');

    String code = '';
    if (consonants.length >= 3) {
      code = consonants.substring(0, 3);
    } else {
      code = consonants + vowels;
      if (code.length > 3) {
        code = code.substring(0, 3);
      } else {
        code = code.padRight(3, 'X');
      }
    }
    return code;
  }

  static String _getFirstNameCode(String firstName) {
    final norm = _normalize(firstName);
    final consonants = norm.replaceAll(RegExp('[AEIOU]'), '');
    final vowels = norm.replaceAll(RegExp('[^AEIOU]'), '');

    String code = '';
    if (consonants.length >= 4) {
      // If there are 4 or more consonants, take 1st, 3rd, and 4th
      code = '${consonants[0]}${consonants[2]}${consonants[3]}';
    } else {
      if (consonants.length >= 3) {
        code = consonants.substring(0, 3);
      } else {
        code = consonants + vowels;
        if (code.length > 3) {
          code = code.substring(0, 3);
        } else {
          code = code.padRight(3, 'X');
        }
      }
    }
    return code;
  }

  static String _getDateAndGenderCode(DateTime dob, String gender) {
    final yearStr = (dob.year % 100).toString().padLeft(2, '0');

    final monthLetters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'H',
      'L',
      'M',
      'P',
      'R',
      'S',
      'T',
    ];
    final monthStr = monthLetters[dob.month - 1];

    final isFemale = gender == 'F';
    final dayVal = dob.day + (isFemale ? 40 : 0);
    final dayStr = dayVal.toString().padLeft(2, '0');

    return '$yearStr$monthStr$dayStr';
  }

  static String _getCheckCharacter(String partialCode) {
    final oddMap = {
      '0': 1,
      '1': 0,
      '2': 5,
      '3': 7,
      '4': 9,
      '5': 13,
      '6': 15,
      '7': 17,
      '8': 19,
      '9': 21,
      'A': 1,
      'B': 0,
      'C': 5,
      'D': 7,
      'E': 9,
      'F': 13,
      'G': 15,
      'H': 17,
      'I': 19,
      'J': 21,
      'K': 2,
      'L': 4,
      'M': 18,
      'N': 20,
      'O': 11,
      'P': 3,
      'Q': 6,
      'R': 8,
      'S': 12,
      'T': 14,
      'U': 16,
      'V': 10,
      'W': 22,
      'X': 25,
      'Y': 24,
      'Z': 23,
    };

    final evenMap = {
      '0': 0,
      '1': 1,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      'A': 0,
      'B': 1,
      'C': 2,
      'D': 3,
      'E': 4,
      'F': 5,
      'G': 6,
      'H': 7,
      'I': 8,
      'J': 9,
      'K': 10,
      'L': 11,
      'M': 12,
      'N': 13,
      'O': 14,
      'P': 15,
      'Q': 16,
      'R': 17,
      'S': 18,
      'T': 19,
      'U': 20,
      'V': 21,
      'W': 22,
      'X': 23,
      'Y': 24,
      'Z': 25,
    };

    int sum = 0;
    for (int i = 0; i < 15; i++) {
      final char = partialCode[i];
      final isOddPosition =
          (i + 1) % 2 !=
          0; // 1-based odd positions: 1st (index 0), 3rd (index 2), etc.
      if (isOddPosition) {
        sum += oddMap[char] ?? 0;
      } else {
        sum += evenMap[char] ?? 0;
      }
    }

    const checkLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return checkLetters[sum % 26];
  }
}
