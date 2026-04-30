// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpRequestResponse _$OtpRequestResponseFromJson(Map<String, dynamic> json) =>
    _OtpRequestResponse(
      message: json['message'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
      otp: json['otp'] as String?,
    );

Map<String, dynamic> _$OtpRequestResponseToJson(_OtpRequestResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'expiresInSeconds': instance.expiresInSeconds,
      if (instance.otp case final value?) 'otp': value,
    };
