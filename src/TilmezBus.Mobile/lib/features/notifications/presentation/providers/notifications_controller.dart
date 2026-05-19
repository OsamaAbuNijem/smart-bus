import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/notifications/push_notification_service.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/notifications/data/repositories/notifications_repository.dart';
import 'package:smart_bus/features/notifications/domain/entities/notification_item.dart';

part 'notifications_controller.g.dart';

/// Loads the current user's inbox and exposes mark-read mutations. Auto
/// refreshes when the auth state changes or a new FCM push arrives.
@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<List<NotificationItem>> build() async {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) return const [];

    // Re-fetch the inbox whenever a foreground push arrives so the page
    // updates live without the user having to pull-to-refresh.
    ref.listen(fcmForegroundMessagesProvider, (_, _) {
      ref.invalidateSelf();
    });

    final repo = ref.watch(notificationsRepositoryProvider);
    return repo.getMine();
  }

  Future<void> refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(notificationsRepositoryProvider).getMine());
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // Optimistic update — if the API call fails the next refresh will fix
    // the read state. Avoids a flash on tap.
    state = AsyncValue.data([
      for (final n in current)
        if (n.id == id) NotificationItem(
              id: n.id, title: n.title, message: n.message,
              type: n.type, isRead: true, createdAt: n.createdAt,
            )
        else n
    ]);
    try {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
    } catch (_) { /* swallow — retried on next refresh */ }
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final n in current)
        NotificationItem(
          id: n.id, title: n.title, message: n.message,
          type: n.type, isRead: true, createdAt: n.createdAt,
        )
    ]);
    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
    } catch (_) { /* swallow */ }
  }
}

/// Convenience: how many unread items the parent has right now. Drives the
/// badge on the home-screen bell icon.
@riverpod
int notificationsUnreadCount(Ref ref) {
  final list = ref.watch(notificationsControllerProvider).valueOrNull;
  if (list == null) return 0;
  return list.where((n) => !n.isRead).length;
}
