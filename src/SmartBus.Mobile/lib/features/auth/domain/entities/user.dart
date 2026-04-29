import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole {
  parent,
  driver,
  assistant;

  String get apiValue => switch (this) {
        UserRole.parent => 'Parent',
        UserRole.driver => 'Driver',
        UserRole.assistant => 'Assistant',
      };

  static UserRole fromApi(String value) =>
      UserRole.values.firstWhere(
        (r) => r.apiValue.toLowerCase() == value.toLowerCase(),
        orElse: () => UserRole.parent,
      );
}

/// Domain entity. Pure Dart, no JSON, no framework. The data layer maps
/// API DTOs into this; presentation reads it.
@freezed
abstract class User with _$User {
  const factory User({
    required String fullName,
    required String phoneNumber,
    required UserRole role,
    required String entityId,
    required DateTime tokenExpiresAt,
  }) = _User;
}
