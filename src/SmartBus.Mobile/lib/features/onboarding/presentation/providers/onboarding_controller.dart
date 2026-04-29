import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/storage/secure_storage.dart';

part 'onboarding_controller.g.dart';

/// Tracks whether the user has completed the onboarding flow at least once.
/// Persisted in [SecureStorage] so it survives reinstalls only as long as
/// the keystore does (acceptable trade-off for a one-time UX flag).
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  Future<bool> build() => ref.watch(secureStorageProvider).readOnboardingSeen();

  Future<void> markSeen() async {
    await ref.read(secureStorageProvider).writeOnboardingSeen();
    state = const AsyncValue.data(true);
  }
}
