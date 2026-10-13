import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

/// Centralized test & preview fixtures for contacts and birthplaces.
abstract final class TestContactFixtures {
  /// Standard Rome birthplace fixture.
  static const Birthplace rome =
      Birthplace(name: 'Roma', state: 'RM', code: 'H501');

  /// Standard Milan birthplace fixture.
  static const Birthplace milan =
      Birthplace(name: 'Milano', state: 'MI', code: 'F205');

  /// Standard Naples birthplace fixture.
  static const Birthplace naples =
      Birthplace(name: 'Napoli', state: 'NA', code: 'F839');

  /// Standard Mario Rossi contact fixture.
  static final Contact marioRossi = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1985, 4, 15),
    birthPlace: rome,
    taxCode: 'RSSMRA85D15H501Z',
    listIndex: 0,
  );

  /// Standard Laura Neri contact fixture.
  static final Contact lauraNeri = Contact(
    id: '2',
    firstName: 'Laura',
    lastName: 'Neri',
    gender: 'F',
    birthDate: DateTime(1992, 8, 24),
    birthPlace: milan,
    taxCode: 'NREBNC92M64F205K',
    listIndex: 1,
  );

  /// Standard Giuseppe Verdi contact fixture.
  static final Contact giuseppeVerdi = Contact(
    id: '3',
    firstName: 'Giuseppe',
    lastName: 'Verdi',
    gender: 'M',
    birthDate: DateTime(1978, 11, 2),
    birthPlace: naples,
    taxCode: 'VRDGPP78S02F839T',
    listIndex: 2,
  );

  /// Default collection of sample contacts.
  static List<Contact> get sampleContacts => [
        marioRossi,
        lauraNeri,
        giuseppeVerdi,
      ];

  /// Default collection of sample birthplaces.
  static List<Birthplace> get sampleBirthplaces => const [
        rome,
        milan,
        naples,
      ];
}
