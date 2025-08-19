import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'birthplace.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Birthplace extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String state;

  const Birthplace({required this.name, required this.state});

  factory Birthplace.fromJson(Map<String, dynamic> json) =>
      _$BirthplaceFromJson(json);
  Map<String, dynamic> toJson() => _$BirthplaceToJson(this);

  @override
  String toString() => '$name ($state)';

  @override
  List<Object?> get props => [name, state];
}
