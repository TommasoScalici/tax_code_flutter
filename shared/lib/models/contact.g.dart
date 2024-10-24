// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      taxCode: json['taxCode'] as String,
      birthPlace:
          Birthplace.fromJson(json['birthPlace'] as Map<String, dynamic>),
      birthDate: DateTime.parse(json['birthDate'] as String),
      listIndex: (json['listIndex'] as num).toInt(),
    );

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'taxCode': instance.taxCode,
      'birthPlace': instance.birthPlace,
      'birthDate': instance.birthDate.toIso8601String(),
      'listIndex': instance.listIndex,
    };
