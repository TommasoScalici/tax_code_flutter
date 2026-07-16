// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxCodeData _$TaxCodeDataFromJson(Map<String, dynamic> json) => TaxCodeData(
  fiscalCode: json['cf'] as String,
  allFiscalCodes: (json['all_cf'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TaxCodeDataToJson(TaxCodeData instance) =>
    <String, dynamic>{
      'cf': instance.fiscalCode,
      'all_cf': instance.allFiscalCodes,
    };

TaxCodeResponse _$TaxCodeResponseFromJson(Map<String, dynamic> json) =>
    TaxCodeResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: TaxCodeData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaxCodeResponseToJson(TaxCodeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
