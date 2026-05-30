import 'package:shared/models/birthplace.dart';

/// Represents the data extracted from a document scan,
/// used specifically for pre-populating a form.
class ScannedData {
  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? birthDate;
  final Birthplace? birthPlace;

  const ScannedData({
    this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.birthPlace,
  });

  /// Factory to create an instance from the JSON returned by the Firebase Function.
  factory ScannedData.fromJson(Map<String, dynamic> json) {
    return ScannedData(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      birthPlace: json['birthPlace'] != null && json['birthPlace'] is Map
          ? Birthplace.fromJson(
              Map<String, dynamic>.from(json['birthPlace'] as Map),
            )
          : null,
    );
  }
}
