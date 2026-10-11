import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/gender.dart';
import 'package:shared/utils/timestamp_converter.dart';
import 'package:uuid/uuid.dart';

export 'gender.dart';

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

  @HiveField(8)
  final DateTime? updatedAt;

  const Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.taxCode,
    required this.birthPlace,
    required this.birthDate,
    required this.listIndex,
    this.updatedAt,
  });

  /// Convenience getter for typed [Gender], defaulting to [Gender.male] if invalid or blank.
  Gender get genderEnum => Gender.fromCode(gender) ?? Gender.male;

  /// Checks whether two contact instances represent the same persistent entity by [id].
  bool isSameEntity(Contact other) => id == other.id;

  /// Creates a new [Contact] with a generated UUID, current timestamp,
  /// and blank fields, ready to be filled in by the user.
  factory Contact.create() {
    return Contact(
      id: const Uuid().v4(),
      firstName: '',
      lastName: '',
      gender: '',
      taxCode: '',
      birthPlace: const Birthplace(name: '', state: ''),
      birthDate: DateTime(1970),
      listIndex: 0,
      updatedAt: DateTime.now(),
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  String toString() =>
      '$firstName $lastName ($gender)'
      ' - ${DateFormat.yMd().format(birthDate)}'
      ' - $birthPlace';

  /// Structural value equality based on all entity and content fields.
  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        gender,
        taxCode,
        birthPlace,
        birthDate,
        listIndex,
      ];
}
