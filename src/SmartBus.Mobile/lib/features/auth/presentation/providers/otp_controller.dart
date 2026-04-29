import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/config/env.dart';
import 'package:smart_bus/core/storage/secure_storage.dart';
import 'package:smart_bus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_bus/features/auth/domain/entities/user.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';

part 'otp_controller.freezed.dart';
part 'otp_controller.g.dart';

@freezed
abstract class OtpFlow with _$OtpFlow {
  const factory OtpFlow.idle() = OtpIdle;
  const factory OtpFlow.pending({
    required String phoneNumber,
    required UserRole role,
    required DateTime expiresAt,
    String? devOtp,
  }) = OtpPending;
  const factory OtpFlow.verified() = OtpVerified;
}

@Riverpod(keepAlive: true)
class OtpController extends _$OtpController {
  @override
  AsyncValue<OtpFlow> build() => const AsyncValue.data(OtpIdle());

  Future<bool> requestOtp({
    required String phoneNumber,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();

    if (Env.demoMode) {
      state = AsyncValue.data(
        OtpFlow.pending(
          phoneNumber: phoneNumber,
          role: role,
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          devOtp: Env.demoOtp,
        ),
      );
      return true;
    }

    final result = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.requestOtp(phoneNumber: phoneNumber, role: role);
      return OtpFlow.pending(
        phoneNumber: phoneNumber,
        role: role,
        expiresAt:
            DateTime.now().add(Duration(seconds: res.expiresInSeconds)),
        devOtp: res.devOtp,
      );
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> verifyOtp(String code) async {
    final pending = state.valueOrNull;
    if (pending is! OtpPending) return false;

    state = const AsyncValue.loading();

    if (Env.demoMode) {
      if (code != Env.demoOtp) {
        state = AsyncValue.data(pending);
        return false;
      }
      final now = DateTime.now().toUtc();
      final expires = now.add(const Duration(hours: 24));
      final user = User(
        fullName: 'Demo Parent',
        phoneNumber: pending.phoneNumber,
        role: pending.role,
        entityId: 'demo-parent',
        tokenExpiresAt: expires,
      );
      // Persist a fake session so a cold start lands directly on /home.
      final storage = ref.read(secureStorageProvider);
      await Future.wait([
        storage.writeAccessToken('demo-token'),
        storage.writeTokenExpiresAt(expires),
        storage.writeFullName(user.fullName),
        storage.writePhoneNumber(user.phoneNumber),
        storage.writeRole(user.role.apiValue),
        storage.writeEntityId(user.entityId),
      ]);
      ref.read(authControllerProvider.notifier).setUser(user);
      state = const AsyncValue.data(OtpVerified());
      return true;
    }

    final result = await AsyncValue.guard<User>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.verifyOtp(
        phoneNumber: pending.phoneNumber,
        otp: code,
        role: pending.role,
      );
    });

    if (result.hasError) {
      // Restore pending state so the screen stays on the OTP step.
      state = AsyncValue.data(pending);
      return false;
    }

    ref.read(authControllerProvider.notifier).setUser(result.requireValue);
    state = const AsyncValue.data(OtpVerified());
    return true;
  }

  void reset() {
    state = const AsyncValue.data(OtpIdle());
  }
}
