// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      gender: fields[3] as String,
      taxCode: fields[4] as String,
      birthPlace: fields[5] as Birthplace,
      birthDate: fields[6] as DateTime,
      listIndex: (fields[7] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.taxCode)
      ..writeByte(5)
      ..write(obj.birthPlace)
      ..writeByte(6)
      ..write(obj.birthDate)
      ..writeByte(7)
      ..write(obj.listIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  gender: json['gender'] as String,
  taxCode: json['taxCode'] as String,
  birthPlace: Birthplace.fromJson(json['birthPlace'] as Map<String, dynamic>),
  birthDate: const TimestampConverter().fromJson(
    json['birthDate'] as Timestamp,
  ),
  listIndex: (json['listIndex'] as num).toInt(),
);

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'gender': instance.gender,
  'taxCode': instance.taxCode,
  'birthPlace': instance.birthPlace.toJson(),
  'birthDate': const TimestampConverter().toJson(instance.birthDate),
  'listIndex': instance.listIndex,
};
