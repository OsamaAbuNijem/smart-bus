// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpVerifyRequest _$OtpVerifyRequestFromJson(Map<String, dynamic> json) =>
    _OtpVerifyRequest(
      phoneNumber: json['phoneNumber'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$OtpVerifyRequestToJson(_OtpVerifyRequest instance) =>
    <String, dynamic>{'phoneNumber': instance.phoneNumber, 'otp': instance.otp};
