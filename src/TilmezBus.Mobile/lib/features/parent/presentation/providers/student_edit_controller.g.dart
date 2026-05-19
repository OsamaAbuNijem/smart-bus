// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentEditControllerHash() =>
    r'babca7a250b29aa565e7671014a81149fd72858c';

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

abstract class _$StudentEditController
    extends BuildlessAutoDisposeNotifier<AsyncValue<void>> {
  late final String studentId;

  AsyncValue<void> build(String studentId);
}

/// One-shot save controller for the Edit Student screen. `AsyncValue` of
/// void — loading while the PUT is in flight, error if it fails. On success
/// the caller should pop and re-fetch `studentInfoProvider`.
///
/// Copied from [StudentEditController].
@ProviderFor(StudentEditController)
const studentEditControllerProvider = StudentEditControllerFamily();

/// One-shot save controller for the Edit Student screen. `AsyncValue` of
/// void — loading while the PUT is in flight, error if it fails. On success
/// the caller should pop and re-fetch `studentInfoProvider`.
///
/// Copied from [StudentEditController].
class StudentEditControllerFamily extends Family<AsyncValue<void>> {
  /// One-shot save controller for the Edit Student screen. `AsyncValue` of
  /// void — loading while the PUT is in flight, error if it fails. On success
  /// the caller should pop and re-fetch `studentInfoProvider`.
  ///
  /// Copied from [StudentEditController].
  const StudentEditControllerFamily();

  /// One-shot save controller for the Edit Student screen. `AsyncValue` of
  /// void — loading while the PUT is in flight, error if it fails. On success
  /// the caller should pop and re-fetch `studentInfoProvider`.
  ///
  /// Copied from [StudentEditController].
  StudentEditControllerProvider call(String studentId) {
    return StudentEditControllerProvider(studentId);
  }

  @override
  StudentEditControllerProvider getProviderOverride(
    covariant StudentEditControllerProvider provider,
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
  String? get name => r'studentEditControllerProvider';
}

/// One-shot save controller for the Edit Student screen. `AsyncValue` of
/// void — loading while the PUT is in flight, error if it fails. On success
/// the caller should pop and re-fetch `studentInfoProvider`.
///
/// Copied from [StudentEditController].
class StudentEditControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          StudentEditController,
          AsyncValue<void>
        > {
  /// One-shot save controller for the Edit Student screen. `AsyncValue` of
  /// void — loading while the PUT is in flight, error if it fails. On success
  /// the caller should pop and re-fetch `studentInfoProvider`.
  ///
  /// Copied from [StudentEditController].
  StudentEditControllerProvider(String studentId)
    : this._internal(
        () => StudentEditController()..studentId = studentId,
        from: studentEditControllerProvider,
        name: r'studentEditControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentEditControllerHash,
        dependencies: StudentEditControllerFamily._dependencies,
        allTransitiveDependencies:
            StudentEditControllerFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentEditControllerProvider._internal(
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
  AsyncValue<void> runNotifierBuild(covariant StudentEditController notifier) {
    return notifier.build(studentId);
  }

  @override
  Override overrideWith(StudentEditController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudentEditControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudentEditController, AsyncValue<void>>
  createElement() {
    return _StudentEditControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentEditControllerProvider &&
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
mixin StudentEditControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<void>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentEditControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          StudentEditController,
          AsyncValue<void>
        >
    with StudentEditControllerRef {
  _StudentEditControllerProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentEditControllerProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
