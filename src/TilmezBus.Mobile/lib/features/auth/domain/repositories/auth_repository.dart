import 'package:smart_bus/features/auth/domain/entities/user.dart';

class OtpRequestResult {
  const OtpRequestResult({
    required this.message,
    required this.expiresInSeconds,
    required this.role,
    this.devOtp,
  });
  final String message;
  final int expiresInSeconds;
  final UserRole role;
  final String? devOtp;
}

abstract class AuthRepository {
  /// Returns the current user if a valid session exists, otherwise `null`.
  Future<User?> currentUser();

  /// Request an OTP for [phoneNumber]. The role is auto-resolved server-side
  /// and returned in [OtpRequestResult.role]. In dev environments the API
  /// echoes the code back via [OtpRequestResult.devOtp].
  Future<OtpRequestResult> requestOtp({required String phoneNumber});

  /// Verify [otp] and persist the resulting JWT session.
  Future<User> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<void> logout();
}
