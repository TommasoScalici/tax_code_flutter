import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tax_code_response.g.dart';

@JsonSerializable()
class TaxCodeData extends Equatable {
  @JsonKey(name: 'cf')
  final String fiscalCode;

  const TaxCodeData({required this.fiscalCode});

  factory TaxCodeData.fromJson(Map<String, dynamic> json) => _$TaxCodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$TaxCodeDataToJson(this);

  @override
  List<Object> get props => [fiscalCode];
}

@JsonSerializable(explicitToJson: true)
final class TaxCodeResponse extends Equatable {
  final bool status;
  final String message;
  final TaxCodeData data;

  const TaxCodeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaxCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$TaxCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TaxCodeResponseToJson(this);

  @override
  List<Object> get props => [status, message, data];
}
