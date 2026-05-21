// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routedPathHash() => r'53d62d5701c687ba76a0bf9dc5420765228c4820';

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

/// Fetches a driving route between two points from the self-hosted OSRM.
/// The result is a list of LatLng forming a polyline that follows streets.
///
/// We snap each input coordinate to ~111m grid (3 decimal places) so small
/// bus movements reuse the cached route instead of refetching every poll.
///
/// Copied from [routedPath].
@ProviderFor(routedPath)
const routedPathProvider = RoutedPathFamily();

/// Fetches a driving route between two points from the self-hosted OSRM.
/// The result is a list of LatLng forming a polyline that follows streets.
///
/// We snap each input coordinate to ~111m grid (3 decimal places) so small
/// bus movements reuse the cached route instead of refetching every poll.
///
/// Copied from [routedPath].
class RoutedPathFamily extends Family<AsyncValue<List<LatLng>>> {
  /// Fetches a driving route between two points from the self-hosted OSRM.
  /// The result is a list of LatLng forming a polyline that follows streets.
  ///
  /// We snap each input coordinate to ~111m grid (3 decimal places) so small
  /// bus movements reuse the cached route instead of refetching every poll.
  ///
  /// Copied from [routedPath].
  const RoutedPathFamily();

  /// Fetches a driving route between two points from the self-hosted OSRM.
  /// The result is a list of LatLng forming a polyline that follows streets.
  ///
  /// We snap each input coordinate to ~111m grid (3 decimal places) so small
  /// bus movements reuse the cached route instead of refetching every poll.
  ///
  /// Copied from [routedPath].
  RoutedPathProvider call({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return RoutedPathProvider(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
  }

  @override
  RoutedPathProvider getProviderOverride(
    covariant RoutedPathProvider provider,
  ) {
    return call(
      fromLat: provider.fromLat,
      fromLng: provider.fromLng,
      toLat: provider.toLat,
      toLng: provider.toLng,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routedPathProvider';
}

/// Fetches a driving route between two points from the self-hosted OSRM.
/// The result is a list of LatLng forming a polyline that follows streets.
///
/// We snap each input coordinate to ~111m grid (3 decimal places) so small
/// bus movements reuse the cached route instead of refetching every poll.
///
/// Copied from [routedPath].
class RoutedPathProvider extends FutureProvider<List<LatLng>> {
  /// Fetches a driving route between two points from the self-hosted OSRM.
  /// The result is a list of LatLng forming a polyline that follows streets.
  ///
  /// We snap each input coordinate to ~111m grid (3 decimal places) so small
  /// bus movements reuse the cached route instead of refetching every poll.
  ///
  /// Copied from [routedPath].
  RoutedPathProvider({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) : this._internal(
         (ref) => routedPath(
           ref as RoutedPathRef,
           fromLat: fromLat,
           fromLng: fromLng,
           toLat: toLat,
           toLng: toLng,
         ),
         from: routedPathProvider,
         name: r'routedPathProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$routedPathHash,
         dependencies: RoutedPathFamily._dependencies,
         allTransitiveDependencies: RoutedPathFamily._allTransitiveDependencies,
         fromLat: fromLat,
         fromLng: fromLng,
         toLat: toLat,
         toLng: toLng,
       );

  RoutedPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
  }) : super.internal();

  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;

  @override
  Override overrideWith(
    FutureOr<List<LatLng>> Function(RoutedPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutedPathProvider._internal(
        (ref) => create(ref as RoutedPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fromLat: fromLat,
        fromLng: fromLng,
        toLat: toLat,
        toLng: toLng,
      ),
    );
  }

  @override
  FutureProviderElement<List<LatLng>> createElement() {
    return _RoutedPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutedPathProvider &&
        other.fromLat == fromLat &&
        other.fromLng == fromLng &&
        other.toLat == toLat &&
        other.toLng == toLng;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fromLat.hashCode);
    hash = _SystemHash.combine(hash, fromLng.hashCode);
    hash = _SystemHash.combine(hash, toLat.hashCode);
    hash = _SystemHash.combine(hash, toLng.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutedPathRef on FutureProviderRef<List<LatLng>> {
  /// The parameter `fromLat` of this provider.
  double get fromLat;

  /// The parameter `fromLng` of this provider.
  double get fromLng;

  /// The parameter `toLat` of this provider.
  double get toLat;

  /// The parameter `toLng` of this provider.
  double get toLng;
}

class _RoutedPathProviderElement extends FutureProviderElement<List<LatLng>>
    with RoutedPathRef {
  _RoutedPathProviderElement(super.provider);

  @override
  double get fromLat => (origin as RoutedPathProvider).fromLat;
  @override
  double get fromLng => (origin as RoutedPathProvider).fromLng;
  @override
  double get toLat => (origin as RoutedPathProvider).toLat;
  @override
  double get toLng => (origin as RoutedPathProvider).toLng;
}

String _$routedPathThroughHash() => r'21268d645a81c17977229ccb633174cf91130d7d';

/// Multi-waypoint variant: fetches a street-following polyline through
/// every point in [waypoints], in order. Used by the parent live-tracking
/// map to draw bus → home → school (morning) or bus → home (return) as
/// one continuous route, matching the driver-map look. Coordinates are
/// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
///
/// Copied from [routedPathThrough].
@ProviderFor(routedPathThrough)
const routedPathThroughProvider = RoutedPathThroughFamily();

/// Multi-waypoint variant: fetches a street-following polyline through
/// every point in [waypoints], in order. Used by the parent live-tracking
/// map to draw bus → home → school (morning) or bus → home (return) as
/// one continuous route, matching the driver-map look. Coordinates are
/// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
///
/// Copied from [routedPathThrough].
class RoutedPathThroughFamily extends Family<AsyncValue<List<LatLng>>> {
  /// Multi-waypoint variant: fetches a street-following polyline through
  /// every point in [waypoints], in order. Used by the parent live-tracking
  /// map to draw bus → home → school (morning) or bus → home (return) as
  /// one continuous route, matching the driver-map look. Coordinates are
  /// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
  ///
  /// Copied from [routedPathThrough].
  const RoutedPathThroughFamily();

  /// Multi-waypoint variant: fetches a street-following polyline through
  /// every point in [waypoints], in order. Used by the parent live-tracking
  /// map to draw bus → home → school (morning) or bus → home (return) as
  /// one continuous route, matching the driver-map look. Coordinates are
  /// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
  ///
  /// Copied from [routedPathThrough].
  RoutedPathThroughProvider call({required String waypointsKey}) {
    return RoutedPathThroughProvider(waypointsKey: waypointsKey);
  }

  @override
  RoutedPathThroughProvider getProviderOverride(
    covariant RoutedPathThroughProvider provider,
  ) {
    return call(waypointsKey: provider.waypointsKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routedPathThroughProvider';
}

/// Multi-waypoint variant: fetches a street-following polyline through
/// every point in [waypoints], in order. Used by the parent live-tracking
/// map to draw bus → home → school (morning) or bus → home (return) as
/// one continuous route, matching the driver-map look. Coordinates are
/// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
///
/// Copied from [routedPathThrough].
class RoutedPathThroughProvider extends FutureProvider<List<LatLng>> {
  /// Multi-waypoint variant: fetches a street-following polyline through
  /// every point in [waypoints], in order. Used by the parent live-tracking
  /// map to draw bus → home → school (morning) or bus → home (return) as
  /// one continuous route, matching the driver-map look. Coordinates are
  /// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
  ///
  /// Copied from [routedPathThrough].
  RoutedPathThroughProvider({required String waypointsKey})
    : this._internal(
        (ref) => routedPathThrough(
          ref as RoutedPathThroughRef,
          waypointsKey: waypointsKey,
        ),
        from: routedPathThroughProvider,
        name: r'routedPathThroughProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routedPathThroughHash,
        dependencies: RoutedPathThroughFamily._dependencies,
        allTransitiveDependencies:
            RoutedPathThroughFamily._allTransitiveDependencies,
        waypointsKey: waypointsKey,
      );

  RoutedPathThroughProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.waypointsKey,
  }) : super.internal();

  final String waypointsKey;

  @override
  Override overrideWith(
    FutureOr<List<LatLng>> Function(RoutedPathThroughRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutedPathThroughProvider._internal(
        (ref) => create(ref as RoutedPathThroughRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        waypointsKey: waypointsKey,
      ),
    );
  }

  @override
  FutureProviderElement<List<LatLng>> createElement() {
    return _RoutedPathThroughProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutedPathThroughProvider &&
        other.waypointsKey == waypointsKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, waypointsKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutedPathThroughRef on FutureProviderRef<List<LatLng>> {
  /// The parameter `waypointsKey` of this provider.
  String get waypointsKey;
}

class _RoutedPathThroughProviderElement
    extends FutureProviderElement<List<LatLng>>
    with RoutedPathThroughRef {
  _RoutedPathThroughProviderElement(super.provider);

  @override
  String get waypointsKey => (origin as RoutedPathThroughProvider).waypointsKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
