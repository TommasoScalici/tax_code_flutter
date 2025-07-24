import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'birthplace.dart';

part 'contact.g.dart';

@JsonSerializable(explicitToJson: true)
final class Contact extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String taxCode;
  final Birthplace birthPlace;
  final DateTime birthDate;
  final int listIndex;

  const Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
    required this.listIndex,
  });

  factory Contact.empty() {
    return Contact(
      id: const Uuid().v4(),
      firstName: '',
      lastName: '',
      gender: '',
      taxCode: '',
      birthPlace: Birthplace(name: '', state: ''),
      birthDate: DateTime.now(),
      listIndex: 0,
    );
  }

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? gender,
    String? taxCode,
    Birthplace? birthPlace,
    DateTime? birthDate,
    int? listIndex,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      taxCode: taxCode ?? this.taxCode,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      listIndex: listIndex ?? this.listIndex,
    );
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
      'birthPlace': {'name': birthPlace.name, 'state': birthPlace.state},
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
  String toString() =>
      '$firstName $lastName ($gender)'
      ' - ${DateFormat.yMd().format(birthDate)}'
      ' - ${birthPlace.toString()}';

  @override
  List<Object?> get props => [id];
}

extension ContactNativeMapper on Contact {
  Map<String, dynamic> toNativeMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'taxCode': taxCode,
    'birthPlace': {'name': birthPlace.name, 'state': birthPlace.state},
    'birthDate': birthDate.toString(),
    'listIndex': listIndex,
  };
}
