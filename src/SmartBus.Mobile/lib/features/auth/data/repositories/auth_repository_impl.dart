import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/storage/secure_storage.dart';
import 'package:smart_bus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_bus/features/auth/data/models/otp_request_request.dart';
import 'package:smart_bus/features/auth/data/models/otp_verify_request.dart';
import 'package:smart_bus/features/auth/domain/entities/user.dart';
import 'package:smart_bus/features/auth/domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);
  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  @override
  Future<User?> currentUser() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) return null;

    final expiresAt = await _storage.readTokenExpiresAt();
    if (expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc())) {
      await _storage.clearAuth();
      return null;
    }

    final fullName = await _storage.readFullName();
    final phone = await _storage.readPhoneNumber();
    final roleStr = await _storage.readRole();
    final entityId = await _storage.readEntityId();
    if (fullName == null || phone == null || roleStr == null || entityId == null) {
      return null;
    }

    return User(
      fullName: fullName,
      phoneNumber: phone,
      role: UserRole.fromApi(roleStr),
      entityId: entityId,
      tokenExpiresAt: expiresAt ?? DateTime.now().toUtc(),
    );
  }

  @override
  Future<OtpRequestResult> requestOtp({
    required String phoneNumber,
  }) async {
    final dto = await _remote.requestOtp(
      OtpRequestRequest(phoneNumber: phoneNumber),
    );
    return OtpRequestResult(
      message: dto.message,
      expiresInSeconds: dto.expiresInSeconds,
      role: UserRole.fromApi(dto.role),
      devOtp: dto.otp,
    );
  }

  @override
  Future<User> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final dto = await _remote.verifyOtp(
      OtpVerifyRequest(phoneNumber: phoneNumber, otp: otp),
    );
    await Future.wait([
      _storage.writeAccessToken(dto.token),
      _storage.writeTokenExpiresAt(dto.expiresAt),
      _storage.writeFullName(dto.fullName),
      _storage.writePhoneNumber(dto.phoneNumber),
      _storage.writeRole(dto.role),
      _storage.writeEntityId(dto.entityId),
    ]);
    return User(
      fullName: dto.fullName,
      phoneNumber: dto.phoneNumber,
      role: UserRole.fromApi(dto.role),
      entityId: dto.entityId,
      tokenExpiresAt: dto.expiresAt,
    );
  }

  @override
  Future<void> logout() => _storage.clearAuth();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDataSourceProvider),
      ref.watch(secureStorageProvider),
    );
