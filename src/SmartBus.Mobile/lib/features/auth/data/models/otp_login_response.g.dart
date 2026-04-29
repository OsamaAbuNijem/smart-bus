// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpLoginResponse _$OtpLoginResponseFromJson(Map<String, dynamic> json) =>
    _OtpLoginResponse(
      token: json['Token'] as String,
      expiresAt: DateTime.parse(json['ExpiresAt'] as String),
      role: json['Role'] as String,
      fullName: json['FullName'] as String,
      phoneNumber: json['PhoneNumber'] as String,
      entityId: json['EntityId'] as String,
    );

Map<String, dynamic> _$OtpLoginResponseToJson(_OtpLoginResponse instance) =>
    <String, dynamic>{
      'Token': instance.token,
      'ExpiresAt': instance.expiresAt.toIso8601String(),
      'Role': instance.role,
      'FullName': instance.fullName,
      'PhoneNumber': instance.phoneNumber,
      'EntityId': instance.entityId,
    };
