final class Birthplace {
  String name = '';
  String state = '';

  Birthplace({
    required this.name,
    required this.state,
  });

  factory Birthplace.fromJson(Map<String, dynamic> json) {
    return Birthplace(
      name: json['name'],
      state: json['state'],
    );
  }

  @override
  String toString() => '$name ($state)';
}
