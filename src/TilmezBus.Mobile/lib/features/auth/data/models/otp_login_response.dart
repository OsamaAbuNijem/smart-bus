import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_login_response.freezed.dart';
part 'otp_login_response.g.dart';

/// Mirrors `POST /api/v1/auth/otp/verify` response.
@freezed
abstract class OtpLoginResponse with _$OtpLoginResponse {
  const factory OtpLoginResponse({
    required String token,
    required DateTime expiresAt,
    required String role,
    required String fullName,
    required String phoneNumber,
    required String entityId,
    required String refreshToken,
  }) = _OtpLoginResponse;

  factory OtpLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpLoginResponseFromJson(json);
}
