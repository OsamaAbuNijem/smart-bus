// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_location_broadcaster.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripLocationBroadcasterHash() =>
    r'0c95fced12ceb748c4d97306179c5fab9cc8f70e';

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

abstract class _$TripLocationBroadcaster
    extends BuildlessAutoDisposeNotifier<void> {
  late final String busId;

  void build(String busId);
}

/// Broadcasts the assistant device's GPS to the API for a specific bus.
///
/// Started by any screen on which the assistant is actively driving a
/// trip (trip details, trip map) so the parent app sees the bus move in
/// real time. The provider is parameterised by busId so multiple
/// concurrent trips would each get their own broadcaster (in practice
/// only one assistant is in a trip at a time).
///
/// Behaviour:
///   • On start, fire `getCurrentPosition` immediately so the parent
///     gets a fresh fix without waiting for the stream's first emission.
///   • Subscribe to the geolocator stream with a 25 m distance filter —
///     each emission is broadcast (so big movements still surface fast).
///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
///     parent's marker timestamp keeps ticking even when the bus is
///     parked, while keeping API traffic light.
///
/// Errors from the geolocator or the HTTP POST are swallowed by design;
/// a flaky network shouldn't disrupt the assistant's local UI.
///
/// Copied from [TripLocationBroadcaster].
@ProviderFor(TripLocationBroadcaster)
const tripLocationBroadcasterProvider = TripLocationBroadcasterFamily();

/// Broadcasts the assistant device's GPS to the API for a specific bus.
///
/// Started by any screen on which the assistant is actively driving a
/// trip (trip details, trip map) so the parent app sees the bus move in
/// real time. The provider is parameterised by busId so multiple
/// concurrent trips would each get their own broadcaster (in practice
/// only one assistant is in a trip at a time).
///
/// Behaviour:
///   • On start, fire `getCurrentPosition` immediately so the parent
///     gets a fresh fix without waiting for the stream's first emission.
///   • Subscribe to the geolocator stream with a 25 m distance filter —
///     each emission is broadcast (so big movements still surface fast).
///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
///     parent's marker timestamp keeps ticking even when the bus is
///     parked, while keeping API traffic light.
///
/// Errors from the geolocator or the HTTP POST are swallowed by design;
/// a flaky network shouldn't disrupt the assistant's local UI.
///
/// Copied from [TripLocationBroadcaster].
class TripLocationBroadcasterFamily extends Family<void> {
  /// Broadcasts the assistant device's GPS to the API for a specific bus.
  ///
  /// Started by any screen on which the assistant is actively driving a
  /// trip (trip details, trip map) so the parent app sees the bus move in
  /// real time. The provider is parameterised by busId so multiple
  /// concurrent trips would each get their own broadcaster (in practice
  /// only one assistant is in a trip at a time).
  ///
  /// Behaviour:
  ///   • On start, fire `getCurrentPosition` immediately so the parent
  ///     gets a fresh fix without waiting for the stream's first emission.
  ///   • Subscribe to the geolocator stream with a 25 m distance filter —
  ///     each emission is broadcast (so big movements still surface fast).
  ///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
  ///     parent's marker timestamp keeps ticking even when the bus is
  ///     parked, while keeping API traffic light.
  ///
  /// Errors from the geolocator or the HTTP POST are swallowed by design;
  /// a flaky network shouldn't disrupt the assistant's local UI.
  ///
  /// Copied from [TripLocationBroadcaster].
  const TripLocationBroadcasterFamily();

  /// Broadcasts the assistant device's GPS to the API for a specific bus.
  ///
  /// Started by any screen on which the assistant is actively driving a
  /// trip (trip details, trip map) so the parent app sees the bus move in
  /// real time. The provider is parameterised by busId so multiple
  /// concurrent trips would each get their own broadcaster (in practice
  /// only one assistant is in a trip at a time).
  ///
  /// Behaviour:
  ///   • On start, fire `getCurrentPosition` immediately so the parent
  ///     gets a fresh fix without waiting for the stream's first emission.
  ///   • Subscribe to the geolocator stream with a 25 m distance filter —
  ///     each emission is broadcast (so big movements still surface fast).
  ///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
  ///     parent's marker timestamp keeps ticking even when the bus is
  ///     parked, while keeping API traffic light.
  ///
  /// Errors from the geolocator or the HTTP POST are swallowed by design;
  /// a flaky network shouldn't disrupt the assistant's local UI.
  ///
  /// Copied from [TripLocationBroadcaster].
  TripLocationBroadcasterProvider call(String busId) {
    return TripLocationBroadcasterProvider(busId);
  }

  @override
  TripLocationBroadcasterProvider getProviderOverride(
    covariant TripLocationBroadcasterProvider provider,
  ) {
    return call(provider.busId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tripLocationBroadcasterProvider';
}

/// Broadcasts the assistant device's GPS to the API for a specific bus.
///
/// Started by any screen on which the assistant is actively driving a
/// trip (trip details, trip map) so the parent app sees the bus move in
/// real time. The provider is parameterised by busId so multiple
/// concurrent trips would each get their own broadcaster (in practice
/// only one assistant is in a trip at a time).
///
/// Behaviour:
///   • On start, fire `getCurrentPosition` immediately so the parent
///     gets a fresh fix without waiting for the stream's first emission.
///   • Subscribe to the geolocator stream with a 25 m distance filter —
///     each emission is broadcast (so big movements still surface fast).
///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
///     parent's marker timestamp keeps ticking even when the bus is
///     parked, while keeping API traffic light.
///
/// Errors from the geolocator or the HTTP POST are swallowed by design;
/// a flaky network shouldn't disrupt the assistant's local UI.
///
/// Copied from [TripLocationBroadcaster].
class TripLocationBroadcasterProvider
    extends AutoDisposeNotifierProviderImpl<TripLocationBroadcaster, void> {
  /// Broadcasts the assistant device's GPS to the API for a specific bus.
  ///
  /// Started by any screen on which the assistant is actively driving a
  /// trip (trip details, trip map) so the parent app sees the bus move in
  /// real time. The provider is parameterised by busId so multiple
  /// concurrent trips would each get their own broadcaster (in practice
  /// only one assistant is in a trip at a time).
  ///
  /// Behaviour:
  ///   • On start, fire `getCurrentPosition` immediately so the parent
  ///     gets a fresh fix without waiting for the stream's first emission.
  ///   • Subscribe to the geolocator stream with a 25 m distance filter —
  ///     each emission is broadcast (so big movements still surface fast).
  ///   • Heartbeat every 30 s — re-broadcasts a fresh position so the
  ///     parent's marker timestamp keeps ticking even when the bus is
  ///     parked, while keeping API traffic light.
  ///
  /// Errors from the geolocator or the HTTP POST are swallowed by design;
  /// a flaky network shouldn't disrupt the assistant's local UI.
  ///
  /// Copied from [TripLocationBroadcaster].
  TripLocationBroadcasterProvider(String busId)
    : this._internal(
        () => TripLocationBroadcaster()..busId = busId,
        from: tripLocationBroadcasterProvider,
        name: r'tripLocationBroadcasterProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tripLocationBroadcasterHash,
        dependencies: TripLocationBroadcasterFamily._dependencies,
        allTransitiveDependencies:
            TripLocationBroadcasterFamily._allTransitiveDependencies,
        busId: busId,
      );

  TripLocationBroadcasterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.busId,
  }) : super.internal();

  final String busId;

  @override
  void runNotifierBuild(covariant TripLocationBroadcaster notifier) {
    return notifier.build(busId);
  }

  @override
  Override overrideWith(TripLocationBroadcaster Function() create) {
    return ProviderOverride(
      origin: this,
      override: TripLocationBroadcasterProvider._internal(
        () => create()..busId = busId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        busId: busId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TripLocationBroadcaster, void>
  createElement() {
    return _TripLocationBroadcasterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripLocationBroadcasterProvider && other.busId == busId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, busId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TripLocationBroadcasterRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `busId` of this provider.
  String get busId;
}

class _TripLocationBroadcasterProviderElement
    extends AutoDisposeNotifierProviderElement<TripLocationBroadcaster, void>
    with TripLocationBroadcasterRef {
  _TripLocationBroadcasterProviderElement(super.provider);

  @override
  String get busId => (origin as TripLocationBroadcasterProvider).busId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
