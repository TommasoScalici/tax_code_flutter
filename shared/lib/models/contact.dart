import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import 'birthplace.dart';

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
  int listIndex;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
    required this.listIndex,
  });

  void updateFrom(Contact other) {
    firstName = other.firstName;
    lastName = other.lastName;
    gender = other.gender;
    birthDate = other.birthDate;
    birthPlace = other.birthPlace;
    taxCode = other.taxCode;
    listIndex = other.listIndex;
  }

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
      'listIndex': listIndex,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
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
      listIndex: map['listIndex'] ?? 0,
    );
  }

  @override
  String toString() => '$firstName $lastName ($gender)'
      ' - ${DateFormat.yMd().format(birthDate)}'
      ' - ${birthPlace.toString()}';
}
