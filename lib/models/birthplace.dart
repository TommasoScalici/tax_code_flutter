import 'package:json_annotation/json_annotation.dart';

part 'birthplace.g.dart';

@JsonSerializable()
final class Birthplace {
  String name;
  String state;

  Birthplace({
    required this.name,
    required this.state,
  });

  factory Birthplace.fromJson(Map<String, dynamic> json) =>
      _$BirthplaceFromJson(json);
  Map<String, dynamic> toJson() => _$BirthplaceToJson(this);

  @override
  String toString() => '$name ($state)';
}
