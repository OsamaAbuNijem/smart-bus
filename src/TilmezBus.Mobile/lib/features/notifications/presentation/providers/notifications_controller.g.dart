// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsUnreadCountHash() =>
    r'a06f7a8ac35eb15702c3655cee0130866689c0d3';

/// Convenience: how many unread items the parent has right now. Drives the
/// badge on the home-screen bell icon.
///
/// Copied from [notificationsUnreadCount].
@ProviderFor(notificationsUnreadCount)
final notificationsUnreadCountProvider = AutoDisposeProvider<int>.internal(
  notificationsUnreadCount,
  name: r'notificationsUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsUnreadCountRef = AutoDisposeProviderRef<int>;
String _$notificationsControllerHash() =>
    r'0fcea20179033fe34c6af390acc78f2da290299d';

/// Loads the current user's inbox and exposes mark-read mutations. Auto
/// refreshes when the auth state changes or a new FCM push arrives.
///
/// Copied from [NotificationsController].
@ProviderFor(NotificationsController)
final notificationsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationsController,
      List<NotificationItem>
    >.internal(
      NotificationsController.new,
      name: r'notificationsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationsController =
    AutoDisposeAsyncNotifier<List<NotificationItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
