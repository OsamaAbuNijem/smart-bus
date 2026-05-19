import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required String id,
    required String title,
    required String message,
    // API uses JsonStringEnumConverter → comes through as the enum name.
    required String type,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
}

@freezed
abstract class NotificationsPageDto with _$NotificationsPageDto {
  const factory NotificationsPageDto({
    required List<NotificationDto> items,
    required int totalCount,
    required int pageNumber,
    required int pageSize,
    required int totalPages,
  }) = _NotificationsPageDto;

  factory NotificationsPageDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationsPageDtoFromJson(json);
}
