// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushNotificationServiceHash() =>
    r'ed710656ae992d274bfdab60267f98fe085e05ec';

/// See also [pushNotificationService].
@ProviderFor(pushNotificationService)
final pushNotificationServiceProvider =
    Provider<PushNotificationService>.internal(
      pushNotificationService,
      name: r'pushNotificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pushNotificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushNotificationServiceRef = ProviderRef<PushNotificationService>;
String _$fcmDeviceTokenHash() => r'f3b76064815f64ac5020e562d464fd991c4a886a';

/// Init lifecycle: request permission + return current FCM token.
/// Watching this provider triggers initialization once per app run.
///
/// Copied from [fcmDeviceToken].
@ProviderFor(fcmDeviceToken)
final fcmDeviceTokenProvider = FutureProvider<String?>.internal(
  fcmDeviceToken,
  name: r'fcmDeviceTokenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmDeviceTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmDeviceTokenRef = FutureProviderRef<String?>;
String _$fcmTokenStreamHash() => r'9bd4b3892f098774195d07681e623d4ff5721632';

/// See also [fcmTokenStream].
@ProviderFor(fcmTokenStream)
final fcmTokenStreamProvider = StreamProvider<String>.internal(
  fcmTokenStream,
  name: r'fcmTokenStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenStreamRef = StreamProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
