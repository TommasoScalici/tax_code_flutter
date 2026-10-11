/// Represents the gender for Italian Tax Code (Codice Fiscale) calculations.
enum Gender {
  male('M'),
  female('F');

  /// The standard single-letter code ('M' or 'F') used in official tax code formulas.
  final String code;

  const Gender(this.code);

  /// Parses a string representation (e.g. 'M', 'F', 'male', 'female') into a [Gender].
  /// Returns null if the code is unrecognized or null.
  static Gender? fromCode(String? code) {
    if (code == null) return null;
    final upper = code.trim().toUpperCase();
    if (upper == 'M' || upper == 'MALE') return Gender.male;
    if (upper == 'F' || upper == 'FEMALE') return Gender.female;
    return null;
  }

  /// Whether this gender is male.
  bool get isMale => this == Gender.male;

  /// Whether this gender is female.
  bool get isFemale => this == Gender.female;

  @override
  String toString() => code;
}
