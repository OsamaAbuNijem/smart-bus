// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tracking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$liveTrackingControllerHash() =>
    r'1a067c35329f11ea5d162ca712a801b2389db1c8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$LiveTrackingController
    extends BuildlessAutoDisposeAsyncNotifier<LiveTracking> {
  late final String studentId;

  FutureOr<LiveTracking> build(String studentId);
}

/// Initial snapshot loaded over HTTP. SignalR updates the bus location in
/// place via [LiveTrackingController.applyLocation].
///
/// Copied from [LiveTrackingController].
@ProviderFor(LiveTrackingController)
const liveTrackingControllerProvider = LiveTrackingControllerFamily();

/// Initial snapshot loaded over HTTP. SignalR updates the bus location in
/// place via [LiveTrackingController.applyLocation].
///
/// Copied from [LiveTrackingController].
class LiveTrackingControllerFamily extends Family<AsyncValue<LiveTracking>> {
  /// Initial snapshot loaded over HTTP. SignalR updates the bus location in
  /// place via [LiveTrackingController.applyLocation].
  ///
  /// Copied from [LiveTrackingController].
  const LiveTrackingControllerFamily();

  /// Initial snapshot loaded over HTTP. SignalR updates the bus location in
  /// place via [LiveTrackingController.applyLocation].
  ///
  /// Copied from [LiveTrackingController].
  LiveTrackingControllerProvider call(String studentId) {
    return LiveTrackingControllerProvider(studentId);
  }

  @override
  LiveTrackingControllerProvider getProviderOverride(
    covariant LiveTrackingControllerProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'liveTrackingControllerProvider';
}

/// Initial snapshot loaded over HTTP. SignalR updates the bus location in
/// place via [LiveTrackingController.applyLocation].
///
/// Copied from [LiveTrackingController].
class LiveTrackingControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LiveTrackingController,
          LiveTracking
        > {
  /// Initial snapshot loaded over HTTP. SignalR updates the bus location in
  /// place via [LiveTrackingController.applyLocation].
  ///
  /// Copied from [LiveTrackingController].
  LiveTrackingControllerProvider(String studentId)
    : this._internal(
        () => LiveTrackingController()..studentId = studentId,
        from: liveTrackingControllerProvider,
        name: r'liveTrackingControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$liveTrackingControllerHash,
        dependencies: LiveTrackingControllerFamily._dependencies,
        allTransitiveDependencies:
            LiveTrackingControllerFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  LiveTrackingControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final String studentId;

  @override
  FutureOr<LiveTracking> runNotifierBuild(
    covariant LiveTrackingController notifier,
  ) {
    return notifier.build(studentId);
  }

  @override
  Override overrideWith(LiveTrackingController Function() create) {
    return ProviderOverride(
      origin: this,
      override: LiveTrackingControllerProvider._internal(
        () => create()..studentId = studentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LiveTrackingController, LiveTracking>
  createElement() {
    return _LiveTrackingControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveTrackingControllerProvider &&
        other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LiveTrackingControllerRef
    on AutoDisposeAsyncNotifierProviderRef<LiveTracking> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _LiveTrackingControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LiveTrackingController,
          LiveTracking
        >
    with LiveTrackingControllerRef {
  _LiveTrackingControllerProviderElement(super.provider);

  @override
  String get studentId => (origin as LiveTrackingControllerProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
