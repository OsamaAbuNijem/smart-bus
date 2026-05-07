import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_request_response.freezed.dart';
part 'otp_request_response.g.dart';

/// Mirrors `POST /api/v1/auth/otp/request` response.
/// `Otp` is only populated in Development.
@freezed
abstract class OtpRequestResponse with _$OtpRequestResponse {
  const factory OtpRequestResponse({
    required String message,
    required int expiresInSeconds,
    required String role,
    String? otp,
  }) = _OtpRequestResponse;

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestResponseFromJson(json);
}
