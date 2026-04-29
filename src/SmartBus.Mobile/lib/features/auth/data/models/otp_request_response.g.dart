// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpRequestResponse _$OtpRequestResponseFromJson(Map<String, dynamic> json) =>
    _OtpRequestResponse(
      message: json['Message'] as String,
      expiresInSeconds: (json['ExpiresInSeconds'] as num).toInt(),
      otp: json['Otp'] as String?,
    );

Map<String, dynamic> _$OtpRequestResponseToJson(_OtpRequestResponse instance) =>
    <String, dynamic>{
      'Message': instance.message,
      'ExpiresInSeconds': instance.expiresInSeconds,
      if (instance.otp case final value?) 'Otp': value,
    };
