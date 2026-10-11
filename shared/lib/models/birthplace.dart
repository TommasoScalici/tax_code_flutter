import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/utils/birthplace_search_filter.dart';

part 'birthplace.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Birthplace extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String state;
  @HiveField(2)
  final String code;

  // Cached pre-normalized fields for instant O(1) autocomplete lookups
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? _normalizedName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? _normalizedState;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? _normalizedFull;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String>? _nameWords;

  const Birthplace({
    required this.name,
    required this.state,
    this.code = '',
    String? normalizedName,
    String? normalizedState,
    String? normalizedFull,
    List<String>? nameWords,
  })  : _normalizedName = normalizedName,
        _normalizedState = normalizedState,
        _normalizedFull = normalizedFull,
        _nameWords = nameWords;

  factory Birthplace.fromJson(Map<String, dynamic> json) =>
      _$BirthplaceFromJson(json).withPrecomputedNormalizedData();

  Map<String, dynamic> toJson() => _$BirthplaceToJson(this);

  /// Returns a new [Birthplace] instance with pre-computed normalized search fields.
  Birthplace withPrecomputedNormalizedData() {
    final normName = BirthplaceSearchFilter.normalize(name);
    final normState = BirthplaceSearchFilter.normalize(state);
    return Birthplace(
      name: name,
      state: state,
      code: code,
      normalizedName: normName,
      normalizedState: normState,
      normalizedFull: '$normName $normState',
      nameWords: normName.split(' '),
    );
  }

  /// Normalized municipality name for instant search indexing.
  String get normalizedName =>
      _normalizedName ?? BirthplaceSearchFilter.normalize(name);

  /// Normalized province / state code for instant search indexing.
  String get normalizedState =>
      _normalizedState ?? BirthplaceSearchFilter.normalize(state);

  /// Combined normalized name and state (e.g. "roma rm").
  String get normalizedFull =>
      _normalizedFull ?? '$normalizedName $normalizedState';

  /// Pre-split words in municipality name.
  List<String> get nameWords =>
      _nameWords ?? normalizedName.split(' ');

  @override
  String toString() => '$name ($state)';

  @override
  List<Object?> get props => [name, state, code];
}
