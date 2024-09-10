// ignore_for_file: non_constant_identifier_names

final class Data {
  String cf;
  List<String> all_cf;

  Data({
    required this.cf,
    required this.all_cf,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      cf: json['cf'],
      all_cf: List<String>.from(json['all_cf']),
    );
  }
}

final class TaxCodeResponse {
  final bool status;
  final String message;
  final Data data;

  TaxCodeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaxCodeResponse.fromJson(Map<String, dynamic> json) {
    return TaxCodeResponse(
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}
