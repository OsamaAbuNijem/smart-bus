import 'package:smart_bus/features/auth/domain/entities/user.dart';

class OtpRequestResult {
  const OtpRequestResult({
    required this.message,
    required this.expiresInSeconds,
    this.devOtp,
  });
  final String message;
  final int expiresInSeconds;
  final String? devOtp;
}

abstract class AuthRepository {
  /// Returns the current user if a valid session exists, otherwise `null`.
  Future<User?> currentUser();

  /// Request an OTP for [phoneNumber] + [role]. The OTP is delivered via SMS.
  /// In dev environments the API echoes the code back via [OtpRequestResult.devOtp].
  Future<OtpRequestResult> requestOtp({
    required String phoneNumber,
    required UserRole role,
  });

  /// Verify [otp] and persist the resulting JWT session.
  Future<User> verifyOtp({
    required String phoneNumber,
    required String otp,
    required UserRole role,
  });

  Future<void> logout();
}
