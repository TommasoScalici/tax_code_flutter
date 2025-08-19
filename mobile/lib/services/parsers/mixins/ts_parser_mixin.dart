part of '../../card_parser_service.dart';

mixin _TsParserMixin on _ParserHelpersMixin {
  Logger get logger;

  Contact? parseTS(List<String> lines) {
    logger.i('--- Using TS Parser ---');

    final lastName = _findValueFuzzy(lines, ['COGNOME']);
    final firstName = _findValueFuzzy(lines, ['NOME']);
    final gender = _findValueFuzzy(lines, ['SESSO']);
    final birthPlaceName = _findValueFuzzy(lines, ['LUOGO']);
    final birthPlaceState = _findValueFuzzy(lines, ['PROVINCIA']);
    final birthDate = _findBirthDateTS(lines);

    final parsedData = {
      'lastName': lastName,
      'firstName': firstName,
      'gender': gender,
      'birthDate': birthDate,
      'birthPlaceName': birthPlaceName,
      'birthPlaceState': birthPlaceState,
      'taxCode': '',
    };

    logger.i('Parsed TS data: $parsedData');

    if (lastName != null &&
        firstName != null &&
        gender != null &&
        birthDate != null &&
        birthPlaceName != null &&
        birthPlaceState != null) {
      final cleanGender = gender.substring(0, 1);
      return Contact(
        id: const Uuid().v4(),
        firstName: firstName.toCapitalCase(),
        lastName: lastName.toCapitalCase(),
        gender: cleanGender,
        taxCode: '',
        birthPlace: Birthplace(
          name: birthPlaceName.toCapitalCase(),
          state: birthPlaceState.toUpperCase(),
        ),
        birthDate: birthDate,
        listIndex: 0,
      );
    }

    logger.w('TS parsing failed. Missing required fields: $parsedData');
    return null;
  }
}
