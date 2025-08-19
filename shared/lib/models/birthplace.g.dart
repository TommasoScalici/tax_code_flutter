// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthplace.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BirthplaceAdapter extends TypeAdapter<Birthplace> {
  @override
  final typeId = 1;

  @override
  Birthplace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Birthplace(name: fields[0] as String, state: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Birthplace obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthplaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Birthplace _$BirthplaceFromJson(Map<String, dynamic> json) =>
    Birthplace(name: json['name'] as String, state: json['state'] as String);

Map<String, dynamic> _$BirthplaceToJson(Birthplace instance) =>
    <String, dynamic>{'name': instance.name, 'state': instance.state};
