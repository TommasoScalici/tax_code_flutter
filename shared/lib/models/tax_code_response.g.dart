// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      fiscalCode: json['cf'] as String,
      allFiscalCodes:
          (json['all_cf'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'cf': instance.fiscalCode,
      'all_cf': instance.allFiscalCodes,
    };

TaxCodeResponse _$TaxCodeResponseFromJson(Map<String, dynamic> json) =>
    TaxCodeResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaxCodeResponseToJson(TaxCodeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
