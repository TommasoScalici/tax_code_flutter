import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tax_code_response.g.dart';

@JsonSerializable()
class TaxCodeData extends Equatable {
  @JsonKey(name: 'cf')
  final String fiscalCode;
  @JsonKey(name: 'all_cf')
  final List<String> allFiscalCodes;

  const TaxCodeData({required this.fiscalCode, required this.allFiscalCodes});

  factory TaxCodeData.fromJson(Map<String, dynamic> json) => _$TaxCodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$TaxCodeDataToJson(this);

  @override
  List<Object> get props => [fiscalCode, allFiscalCodes];
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
