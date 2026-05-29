// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_registrar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceTokenRegistrarHash() =>
    r'2953111ff8b4e9c9f9b0eeeafc44096033b4419a';

/// Registers the current FCM token with the backend whenever the user is
/// authenticated. Idempotent — the API treats it as upsert. Re-registers on
/// FCM token rotation AND on in-app locale changes so the server has the
/// up-to-date `language` to render notification templates against.
///
/// Copied from [DeviceTokenRegistrar].
@ProviderFor(DeviceTokenRegistrar)
final deviceTokenRegistrarProvider =
    AsyncNotifierProvider<DeviceTokenRegistrar, void>.internal(
      DeviceTokenRegistrar.new,
      name: r'deviceTokenRegistrarProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deviceTokenRegistrarHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeviceTokenRegistrar = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
