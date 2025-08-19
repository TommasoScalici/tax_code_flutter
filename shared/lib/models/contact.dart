import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/utils/timestamp_converter.dart';
import 'package:uuid/uuid.dart';

import 'birthplace.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class Contact extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String gender;

  @HiveField(4)
  final String taxCode;

  @HiveField(5)
  final Birthplace birthPlace;

  @HiveField(6)
  @TimestampConverter()
  final DateTime birthDate;

  @HiveField(7)
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
      birthPlace: const Birthplace(name: '', state: ''),
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

  @override
  String toString() => '$firstName $lastName ($gender)'
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
