import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/parent/data/repositories/parent_repository.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';

part 'student_edit_controller.g.dart';

/// One-shot save controller for the Edit Student screen. `AsyncValue` of
/// void — loading while the PUT is in flight, error if it fails. On success
/// the caller should pop and re-fetch `studentInfoProvider`.
@riverpod
class StudentEditController extends _$StudentEditController {
  @override
  AsyncValue<void> build(String studentId) => const AsyncData(null);

  Future<bool> save({
    required String fullName,
    required String grade,
    String? className,
    String? notes,
    required String parentName,
    required String parentPhone,
  }) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return false;

    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(parentRepositoryProvider).updateChildProfile(
            parentId: user.entityId,
            studentId: studentId,
            fullName: fullName,
            grade: grade,
            className: className,
            notes: notes,
            parentName: parentName,
            parentPhone: parentPhone,
          );
    });
    state = result;

    if (!result.hasError) {
      // Refresh the student info + the parent's child list (name/grade may have changed).
      ref.invalidate(studentInfoProvider(studentId));
      ref.invalidate(parentChildrenProvider);
    }
    return !result.hasError;
  }
}
