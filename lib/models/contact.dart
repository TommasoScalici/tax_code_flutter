import 'package:cloud_firestore/cloud_firestore.dart';
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
  String gender;
  String taxCode;
  Birthplace birthPlace;
  DateTime birthDate;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
  }) : id = const Uuid().v4();

  Contact.withId({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
  });

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'taxCode': taxCode,
      'birthPlace': {
        'name': birthPlace.name,
        'state': birthPlace.state,
      },
      'birthDate': Timestamp.fromDate(birthDate),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact.withId(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? '',
      taxCode: map['taxCode'] ?? '',
      birthPlace: Birthplace(
        name: map['birthPlace']['name'],
        state: map['birthPlace']['state'],
      ),
      birthDate: (map['birthDate'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() => '$firstName $lastName ($gender)'
      ' - ${DateFormat.yMd().format(birthDate)}'
      ' - ${birthPlace.toString()}';
}
