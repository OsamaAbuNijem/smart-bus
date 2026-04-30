// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpRequestRequest _$OtpRequestRequestFromJson(Map<String, dynamic> json) =>
    _OtpRequestRequest(
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$OtpRequestRequestToJson(_OtpRequestRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'role': instance.role,
    };
