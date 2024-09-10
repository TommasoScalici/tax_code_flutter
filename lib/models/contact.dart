import 'package:tax_code_flutter/models/birthplace.dart';

final class Contact {
  String firstName = '';
  String lastName = '';
  String sex = '';
  String taxCode = '';
  Birthplace birthPlace = Birthplace(name: '', state: '');
  DateTime? birthDate;
}
