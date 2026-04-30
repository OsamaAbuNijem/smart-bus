// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpLoginResponse _$OtpLoginResponseFromJson(Map<String, dynamic> json) =>
    _OtpLoginResponse(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      entityId: json['entityId'] as String,
    );

Map<String, dynamic> _$OtpLoginResponseToJson(_OtpLoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'role': instance.role,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'entityId': instance.entityId,
    };
