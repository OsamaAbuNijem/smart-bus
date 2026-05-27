// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_registrar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceTokenRegistrarHash() =>
    r'da33fd5499433a916692c91d27e6e9004124f744';

/// Registers the current FCM token with the backend whenever the user is
/// authenticated. Idempotent — the API treats it as upsert. Re-registers on
/// token rotation (Firebase issues a fresh token periodically).
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
