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
String _$studentInfoHash() => r'353fb49a6867a5d6e1cdf7fa11028eb788c7bd8e';

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

/// Detail for a single child (student info screen).
///
/// Copied from [studentInfo].
@ProviderFor(studentInfo)
const studentInfoProvider = StudentInfoFamily();

/// Detail for a single child (student info screen).
///
/// Copied from [studentInfo].
class StudentInfoFamily extends Family<AsyncValue<StudentInfo>> {
  /// Detail for a single child (student info screen).
  ///
  /// Copied from [studentInfo].
  const StudentInfoFamily();

  /// Detail for a single child (student info screen).
  ///
  /// Copied from [studentInfo].
  StudentInfoProvider call(String studentId) {
    return StudentInfoProvider(studentId);
  }

  @override
  StudentInfoProvider getProviderOverride(
    covariant StudentInfoProvider provider,
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
  String? get name => r'studentInfoProvider';
}

/// Detail for a single child (student info screen).
///
/// Copied from [studentInfo].
class StudentInfoProvider extends AutoDisposeFutureProvider<StudentInfo> {
  /// Detail for a single child (student info screen).
  ///
  /// Copied from [studentInfo].
  StudentInfoProvider(String studentId)
    : this._internal(
        (ref) => studentInfo(ref as StudentInfoRef, studentId),
        from: studentInfoProvider,
        name: r'studentInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentInfoHash,
        dependencies: StudentInfoFamily._dependencies,
        allTransitiveDependencies: StudentInfoFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentInfoProvider._internal(
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
    FutureOr<StudentInfo> Function(StudentInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentInfoProvider._internal(
        (ref) => create(ref as StudentInfoRef),
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
  AutoDisposeFutureProviderElement<StudentInfo> createElement() {
    return _StudentInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentInfoProvider && other.studentId == studentId;
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
mixin StudentInfoRef on AutoDisposeFutureProviderRef<StudentInfo> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentInfoProviderElement
    extends AutoDisposeFutureProviderElement<StudentInfo>
    with StudentInfoRef {
  _StudentInfoProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentInfoProvider).studentId;
}

String _$childTripsHash() => r'8dd46075b99cd080345a54732c3ee14fddcbe30e';

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

String _$studentAbsencesHash() => r'd33eee0cf183c2db49c3c6169cfbbb0ca3a079fc';

/// All non-deleted absence requests for the given student, newest first.
///
/// Copied from [studentAbsences].
@ProviderFor(studentAbsences)
const studentAbsencesProvider = StudentAbsencesFamily();

/// All non-deleted absence requests for the given student, newest first.
///
/// Copied from [studentAbsences].
class StudentAbsencesFamily
    extends Family<AsyncValue<List<AbsenceRequestItem>>> {
  /// All non-deleted absence requests for the given student, newest first.
  ///
  /// Copied from [studentAbsences].
  const StudentAbsencesFamily();

  /// All non-deleted absence requests for the given student, newest first.
  ///
  /// Copied from [studentAbsences].
  StudentAbsencesProvider call(String studentId) {
    return StudentAbsencesProvider(studentId);
  }

  @override
  StudentAbsencesProvider getProviderOverride(
    covariant StudentAbsencesProvider provider,
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
  String? get name => r'studentAbsencesProvider';
}

/// All non-deleted absence requests for the given student, newest first.
///
/// Copied from [studentAbsences].
class StudentAbsencesProvider
    extends AutoDisposeFutureProvider<List<AbsenceRequestItem>> {
  /// All non-deleted absence requests for the given student, newest first.
  ///
  /// Copied from [studentAbsences].
  StudentAbsencesProvider(String studentId)
    : this._internal(
        (ref) => studentAbsences(ref as StudentAbsencesRef, studentId),
        from: studentAbsencesProvider,
        name: r'studentAbsencesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentAbsencesHash,
        dependencies: StudentAbsencesFamily._dependencies,
        allTransitiveDependencies:
            StudentAbsencesFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentAbsencesProvider._internal(
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
    FutureOr<List<AbsenceRequestItem>> Function(StudentAbsencesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentAbsencesProvider._internal(
        (ref) => create(ref as StudentAbsencesRef),
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
  AutoDisposeFutureProviderElement<List<AbsenceRequestItem>> createElement() {
    return _StudentAbsencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAbsencesProvider && other.studentId == studentId;
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
mixin StudentAbsencesRef
    on AutoDisposeFutureProviderRef<List<AbsenceRequestItem>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentAbsencesProviderElement
    extends AutoDisposeFutureProviderElement<List<AbsenceRequestItem>>
    with StudentAbsencesRef {
  _StudentAbsencesProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentAbsencesProvider).studentId;
}

String _$tripHistoryHash() => r'bbd53f6c29e16b822ceab88be233acc6bb29121e';

/// Larger trip window for the dedicated history screen (last ~30 entries).
///
/// Copied from [tripHistory].
@ProviderFor(tripHistory)
const tripHistoryProvider = TripHistoryFamily();

/// Larger trip window for the dedicated history screen (last ~30 entries).
///
/// Copied from [tripHistory].
class TripHistoryFamily extends Family<AsyncValue<List<ChildTrip>>> {
  /// Larger trip window for the dedicated history screen (last ~30 entries).
  ///
  /// Copied from [tripHistory].
  const TripHistoryFamily();

  /// Larger trip window for the dedicated history screen (last ~30 entries).
  ///
  /// Copied from [tripHistory].
  TripHistoryProvider call(String studentId) {
    return TripHistoryProvider(studentId);
  }

  @override
  TripHistoryProvider getProviderOverride(
    covariant TripHistoryProvider provider,
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
  String? get name => r'tripHistoryProvider';
}

/// Larger trip window for the dedicated history screen (last ~30 entries).
///
/// Copied from [tripHistory].
class TripHistoryProvider extends AutoDisposeFutureProvider<List<ChildTrip>> {
  /// Larger trip window for the dedicated history screen (last ~30 entries).
  ///
  /// Copied from [tripHistory].
  TripHistoryProvider(String studentId)
    : this._internal(
        (ref) => tripHistory(ref as TripHistoryRef, studentId),
        from: tripHistoryProvider,
        name: r'tripHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tripHistoryHash,
        dependencies: TripHistoryFamily._dependencies,
        allTransitiveDependencies: TripHistoryFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  TripHistoryProvider._internal(
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
    FutureOr<List<ChildTrip>> Function(TripHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TripHistoryProvider._internal(
        (ref) => create(ref as TripHistoryRef),
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
    return _TripHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripHistoryProvider && other.studentId == studentId;
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
mixin TripHistoryRef on AutoDisposeFutureProviderRef<List<ChildTrip>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _TripHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<ChildTrip>>
    with TripHistoryRef {
  _TripHistoryProviderElement(super.provider);

  @override
  String get studentId => (origin as TripHistoryProvider).studentId;
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
