import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tax_code_flutter/models/birthplace.dart';
import 'package:uuid/uuid.dart';

part 'contact.g.dart';

@JsonSerializable()
final class Contact {
  String id;
  String firstName;
  String lastName;
  String sex;
  String taxCode;
  Birthplace birthPlace;
  DateTime birthDate;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
  }) : id = const Uuid().v4();

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  String toString() => '$firstName $lastName ($sex)'
      ' - ${DateFormat.yMd().format(birthDate)}'
      ' - ${birthPlace.toString()}';
}
