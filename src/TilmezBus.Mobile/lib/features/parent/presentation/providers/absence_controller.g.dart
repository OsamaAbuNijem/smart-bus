// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absence_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$absenceControllerHash() => r'bdbf18126e3d18a4a97be58a5f2361c02e57ee49';

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

abstract class _$AbsenceController
    extends BuildlessAutoDisposeNotifier<AsyncValue<void>> {
  late final String studentId;

  AsyncValue<void> build(String studentId);
}

/// One-shot submit controller for the Report Absence screen.
///
/// Copied from [AbsenceController].
@ProviderFor(AbsenceController)
const absenceControllerProvider = AbsenceControllerFamily();

/// One-shot submit controller for the Report Absence screen.
///
/// Copied from [AbsenceController].
class AbsenceControllerFamily extends Family<AsyncValue<void>> {
  /// One-shot submit controller for the Report Absence screen.
  ///
  /// Copied from [AbsenceController].
  const AbsenceControllerFamily();

  /// One-shot submit controller for the Report Absence screen.
  ///
  /// Copied from [AbsenceController].
  AbsenceControllerProvider call(String studentId) {
    return AbsenceControllerProvider(studentId);
  }

  @override
  AbsenceControllerProvider getProviderOverride(
    covariant AbsenceControllerProvider provider,
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
  String? get name => r'absenceControllerProvider';
}

/// One-shot submit controller for the Report Absence screen.
///
/// Copied from [AbsenceController].
class AbsenceControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<AbsenceController, AsyncValue<void>> {
  /// One-shot submit controller for the Report Absence screen.
  ///
  /// Copied from [AbsenceController].
  AbsenceControllerProvider(String studentId)
    : this._internal(
        () => AbsenceController()..studentId = studentId,
        from: absenceControllerProvider,
        name: r'absenceControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$absenceControllerHash,
        dependencies: AbsenceControllerFamily._dependencies,
        allTransitiveDependencies:
            AbsenceControllerFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  AbsenceControllerProvider._internal(
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
  AsyncValue<void> runNotifierBuild(covariant AbsenceController notifier) {
    return notifier.build(studentId);
  }

  @override
  Override overrideWith(AbsenceController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AbsenceControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<AbsenceController, AsyncValue<void>>
  createElement() {
    return _AbsenceControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AbsenceControllerProvider && other.studentId == studentId;
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
mixin AbsenceControllerRef on AutoDisposeNotifierProviderRef<AsyncValue<void>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _AbsenceControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<AbsenceController, AsyncValue<void>>
    with AbsenceControllerRef {
  _AbsenceControllerProviderElement(super.provider);

  @override
  String get studentId => (origin as AbsenceControllerProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
