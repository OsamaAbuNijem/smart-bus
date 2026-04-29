import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_bus/features/auth/domain/entities/user.dart';

part 'auth_controller.g.dart';

/// Single source of truth for "is the user logged in?".
/// Loads the persisted session on cold start; presentation flips it via
/// [setUser] (called by the OTP flow) or [logout].
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.currentUser();
  }

  /// Called by [OtpController] after a successful verify.
  void setUser(User user) {
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
