// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpRequestRequest _$OtpRequestRequestFromJson(Map<String, dynamic> json) =>
    _OtpRequestRequest(
      phoneNumber: json['PhoneNumber'] as String,
      role: json['Role'] as String,
    );

Map<String, dynamic> _$OtpRequestRequestToJson(_OtpRequestRequest instance) =>
    <String, dynamic>{
      'PhoneNumber': instance.phoneNumber,
      'Role': instance.role,
    };
