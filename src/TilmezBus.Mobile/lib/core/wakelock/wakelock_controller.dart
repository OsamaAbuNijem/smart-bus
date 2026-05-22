import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:tilmez_bus/features/auth/domain/entities/user.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';

/// Keeps the device screen awake while the logged-in user is a driver or
/// assistant — they keep the phone in a cradle on the bus and need the map
/// and trip details visible at all times. Parents fall back to the OS
/// auto-lock so we don't drain their battery in the background.
///
/// The provider is registered (via `container.listen` in main) for the
/// lifetime of the app; it rebuilds whenever the auth state changes and
/// flips the wakelock accordingly. WakelockPlus.toggle is idempotent so
/// repeated calls with the same flag are cheap.
final wakelockControllerProvider = Provider<void>((ref) {
  final role = ref.watch(authControllerProvider).valueOrNull?.role;
  final keepAwake = role == UserRole.driver || role == UserRole.assistant;
  // ignore: discarded_futures
  WakelockPlus.toggle(enable: keepAwake);
});
