import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_request_request.freezed.dart';
part 'otp_request_request.g.dart';

@freezed
abstract class OtpRequestRequest with _$OtpRequestRequest {
  const factory OtpRequestRequest({
    required String phoneNumber,
  }) = _OtpRequestRequest;

  factory OtpRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestRequestFromJson(json);
}
