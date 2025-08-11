import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'birthplace.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Birthplace {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String state;

  Birthplace({required this.name, required this.state});

  factory Birthplace.fromJson(Map<String, dynamic> json) =>
      _$BirthplaceFromJson(json);
  Map<String, dynamic> toJson() => _$BirthplaceToJson(this);

  @override
  String toString() => '$name ($state)';
}
