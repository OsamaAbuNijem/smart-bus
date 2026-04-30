// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$parentChildrenHash() => r'f86488558469ee87d684836da80ffafd81a3d0be';

/// All children for the currently signed-in parent.
///
/// Copied from [parentChildren].
@ProviderFor(parentChildren)
final parentChildrenProvider =
    AutoDisposeFutureProvider<List<ParentChild>>.internal(
      parentChildren,
      name: r'parentChildrenProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$parentChildrenHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ParentChildrenRef = AutoDisposeFutureProviderRef<List<ParentChild>>;
String _$childTripsHash() => r'8dd46075b99cd080345a54732c3ee14fddcbe30e';

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

/// Trips for the currently selected child. Family on studentId so each child
/// can be cached independently.
///
/// Copied from [childTrips].
@ProviderFor(childTrips)
const childTripsProvider = ChildTripsFamily();

/// Trips for the currently selected child. Family on studentId so each child
/// can be cached independently.
///
/// Copied from [childTrips].
class ChildTripsFamily extends Family<AsyncValue<List<ChildTrip>>> {
  /// Trips for the currently selected child. Family on studentId so each child
  /// can be cached independently.
  ///
  /// Copied from [childTrips].
  const ChildTripsFamily();

  /// Trips for the currently selected child. Family on studentId so each child
  /// can be cached independently.
  ///
  /// Copied from [childTrips].
  ChildTripsProvider call(String studentId) {
    return ChildTripsProvider(studentId);
  }

  @override
  ChildTripsProvider getProviderOverride(
    covariant ChildTripsProvider provider,
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
  String? get name => r'childTripsProvider';
}

/// Trips for the currently selected child. Family on studentId so each child
/// can be cached independently.
///
/// Copied from [childTrips].
class ChildTripsProvider extends AutoDisposeFutureProvider<List<ChildTrip>> {
  /// Trips for the currently selected child. Family on studentId so each child
  /// can be cached independently.
  ///
  /// Copied from [childTrips].
  ChildTripsProvider(String studentId)
    : this._internal(
        (ref) => childTrips(ref as ChildTripsRef, studentId),
        from: childTripsProvider,
        name: r'childTripsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$childTripsHash,
        dependencies: ChildTripsFamily._dependencies,
        allTransitiveDependencies: ChildTripsFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  ChildTripsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<ChildTrip>> Function(ChildTripsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChildTripsProvider._internal(
        (ref) => create(ref as ChildTripsRef),
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
  AutoDisposeFutureProviderElement<List<ChildTrip>> createElement() {
    return _ChildTripsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildTripsProvider && other.studentId == studentId;
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
mixin ChildTripsRef on AutoDisposeFutureProviderRef<List<ChildTrip>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _ChildTripsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChildTrip>>
    with ChildTripsRef {
  _ChildTripsProviderElement(super.provider);

  @override
  String get studentId => (origin as ChildTripsProvider).studentId;
}

String _$selectedChildIndexHash() =>
    r'f85decc3222e6538ed15d3b3a086775b0f251864';

/// Index of the currently selected child tab. Reset to 0 when [parentChildrenProvider]
/// reloads.
///
/// Copied from [SelectedChildIndex].
@ProviderFor(SelectedChildIndex)
final selectedChildIndexProvider =
    AutoDisposeNotifierProvider<SelectedChildIndex, int>.internal(
      SelectedChildIndex.new,
      name: r'selectedChildIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedChildIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedChildIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
