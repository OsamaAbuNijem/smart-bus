// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingControllerHash() =>
    r'0cf3a4070ca99572f47a6a4f9ce707e2e28f5895';

/// Tracks whether the user has completed the onboarding flow at least once.
/// Persisted in [SecureStorage] so it survives reinstalls only as long as
/// the keystore does (acceptable trade-off for a one-time UX flag).
///
/// Copied from [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>.internal(
      OnboardingController.new,
      name: r'onboardingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingController = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
