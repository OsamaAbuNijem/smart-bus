// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeControllerHash() => r'76b7c7198a384920e7f6b2bcfb3cbf66107096aa';

/// Holds the user's chosen locale (`en` or `ar`). `null` means follow the
/// system locale. Persisted in [SecureStorage].
///
/// Copied from [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale?>.internal(
      LocaleController.new,
      name: r'localeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleController = AsyncNotifier<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
