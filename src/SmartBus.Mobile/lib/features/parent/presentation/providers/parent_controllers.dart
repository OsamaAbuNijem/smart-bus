import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/parent/data/repositories/parent_repository.dart';
import 'package:smart_bus/features/parent/domain/entities/child_trip.dart';
import 'package:smart_bus/features/parent/domain/entities/parent_child.dart';

part 'parent_controllers.g.dart';

/// All children for the currently signed-in parent.
@riverpod
Future<List<ParentChild>> parentChildren(Ref ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.watch(parentRepositoryProvider);
  return repo.getChildren(user.entityId);
}

/// Index of the currently selected child tab. Reset to 0 when [parentChildrenProvider]
/// reloads.
@riverpod
class SelectedChildIndex extends _$SelectedChildIndex {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// Trips for the currently selected child. Family on studentId so each child
/// can be cached independently.
@riverpod
Future<List<ChildTrip>> childTrips(Ref ref, String studentId) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null || studentId.isEmpty) return const [];
  final repo = ref.watch(parentRepositoryProvider);
  return repo.getChildTrips(parentId: user.entityId, studentId: studentId);
}
