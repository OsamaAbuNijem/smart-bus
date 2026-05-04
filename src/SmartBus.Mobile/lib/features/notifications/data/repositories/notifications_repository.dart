import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:smart_bus/features/notifications/domain/entities/notification_item.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  NotificationsRepository(this._remote);
  final NotificationsRemoteDataSource _remote;

  Future<List<NotificationItem>> getMine() async {
    final page = await _remote.getMine(pageNumber: 1, pageSize: 100);
    return page.items
        .map((dto) => NotificationItem(
              id: dto.id,
              title: dto.title,
              message: dto.message,
              type: NotificationKind.fromName(dto.type),
              isRead: dto.isRead,
              createdAt: dto.createdAt,
            ))
        .toList(growable: false);
  }

  Future<void> markAsRead(String id) => _remote.markAsRead(id);
  Future<void> markAllAsRead() => _remote.markAllAsRead();
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    NotificationsRepository(ref.watch(notificationsRemoteDataSourceProvider));
