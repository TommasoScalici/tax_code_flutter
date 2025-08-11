import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tax_code_response.g.dart';

@JsonSerializable()
class Data extends Equatable {
  @JsonKey(name: 'cf')
  final String fiscalCode;
  @JsonKey(name: 'all_cf')
  final List<String> allFiscalCodes;

  const Data({required this.fiscalCode, required this.allFiscalCodes});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);

  @override
  List<Object> get props => [fiscalCode, allFiscalCodes];
}

@JsonSerializable(explicitToJson: true)
final class TaxCodeResponse extends Equatable {
  final bool status;
  final String message;
  final Data data;

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
