// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MethodModel _$MethodModelFromJson(Map<String, dynamic> json) {
  return MethodModel(
    description: json['description'] as String,
    enabled: json['enabled'] as bool,
    rateLimit: (json['rate_limit'] as num)?.toDouble(),
    authRateLimit: (json['auth_rate_limit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$MethodModelToJson(MethodModel instance) =>
    <String, dynamic>{
      'description': instance.description,
      'enabled': instance.enabled,
      'rate_limit': instance.rateLimit,
      'auth_rate_limit': instance.authRateLimit,
    };
