part of '../../card_parser_service.dart';

mixin _CieParserMixin on _ParserHelpersMixin {
  Logger get logger;

  /// Parse Carta d'Identità Elettronica (CIE) text into a Contact object.
  /// Uses fuzzy search to find relevant fields like name, surname,
  /// sex, and birth information.
  /// Returns a Contact object if all required fields are found, otherwise null.
  Contact? parseCIE(List<String> lines) {
    logger.i('--- Using CIE Parser ---');

    final lastNameResult = _findValueOnNextLineFuzzy(lines, [
      'COGNOME',
      'SURNAME',
    ]);

    final firstNameResult = _findValueOnNextLineFuzzy(lines, [
      'NOME',
      'NAME',
    ], lineOffset: lastNameResult?.lineIndex ?? 0);

    final gender = _findGenderFuzzy(lines);
    final birthInfo = _extractBirthInfoCIE(lines);

    final parsedData = {
      'lastName': lastNameResult?.value,
      'firstName': firstNameResult?.value,
      'gender': gender,
      'birthDate': birthInfo?.birthDate,
      'birthPlaceName': birthInfo?.birthPlaceName,
      'birthPlaceState': birthInfo?.birthPlaceState,
    };

    if (lastNameResult != null &&
        firstNameResult != null &&
        gender != null &&
        birthInfo != null) {
      return Contact(
        id: const Uuid().v4(),
        firstName: firstNameResult.value.toCapitalCase(),
        lastName: lastNameResult.value.toCapitalCase(),
        gender: gender,
        taxCode: '',
        birthPlace: Birthplace(
          name: birthInfo.birthPlaceName!.toCapitalCase(),
          state: birthInfo.birthPlaceState!.toUpperCase(),
        ),
        birthDate: birthInfo.birthDate!,
        listIndex: 0,
      );
    }

    logger.w('CIE parsing failed. Missing required fields: $parsedData');
    return null;
  }
}
