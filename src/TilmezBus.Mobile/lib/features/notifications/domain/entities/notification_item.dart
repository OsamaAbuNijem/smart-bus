import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';

/// Mirrors the API's `NotificationType` enum (serialised as the name).
enum NotificationKind {
  tripStarted,
  tripCompleted,
  busArriving,
  busArrived,
  systemAlert,
  studentBoarded,
  studentArrived,
  absenceConfirmed,
  driverMessage,
  schoolNotice;

  /// Map the API's PascalCase name to a Dart enum. Unknown names fall
  /// through to systemAlert so the inbox never blows up on a new server-side
  /// type that the client hasn't shipped yet.
  static NotificationKind fromName(String? raw) {
    if (raw == null || raw.isEmpty) return NotificationKind.systemAlert;
    final lower = raw[0].toLowerCase() + raw.substring(1);
    for (final v in NotificationKind.values) {
      if (v.name == lower) return v;
    }
    return NotificationKind.systemAlert;
  }
}

@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String title,
    required String message,
    required NotificationKind type,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationItem;
}
